using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Services.Auth;
using RPGTableHelper.WebApi.Services.Images;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Images for your character, e.g. the picture of a <c>singleImage</c> stat. The same upload the app uses for
    /// character portraits.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.V1)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalImagesController : ExternalApiControllerBase
    {
        private readonly IImageUploadService _imageUploadService;

        public ExternalImagesController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            IImageUploadService imageUploadService
        )
            : base(queryProcessor, userContext)
        {
            _imageUploadService = imageUploadService;
        }

        /// <summary>
        /// Uploads an image for the campaign, sent as <c>multipart/form-data</c> with the file <c>image</c> (PNG or
        /// JPEG, at most 10 MB). Put the returned <c>path</c> into a <c>singleImage</c> stat's <c>imageUrl</c>.
        /// Anyone with the link can load the image.
        /// </summary>
        /// <response code="201">The uploaded image</response>
        /// <response code="400">If the file is no PNG or JPEG or too big</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.CharactersWrite)]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ExternalImageDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("campaigns/{campaignId:guid}/images")]
        public async Task<ActionResult<ExternalImageDto>> UploadImageAsync(
            Guid campaignId,
            [FromForm] ExternalImageUploadRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("The campaign does not exist or you are not part of it.");
            }

            var imageProblem = await _imageUploadService.ValidateAsync(request.Image, cancellationToken).ConfigureAwait(false);
            if (imageProblem != null)
            {
                return InvalidRequest(imageProblem, new List<string> { $"image: {imageProblem}" });
            }

            var image = await _imageUploadService
                .StoreAsync(campaign.Id, UserContext.User.UserIdentifier, request.Image, cancellationToken)
                .ConfigureAwait(false);
            if (image == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not store the image.");
            }

            var fullUrl = ToFullImageUrl(image.PublicUrl);
            return Created(fullUrl, new ExternalImageDto { Path = image.PublicUrl, ImageUrl = fullUrl });
        }
    }
}
