using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("/[controller]")]
    public class PublicController : ControllerBase
    {
        public static readonly string MinimalAppVersionSupported = "1.0.0";

        /// <summary>
        /// The semantic api version reported to clients via <see cref="GetCapabilities"/>.
        /// </summary>
        public static readonly string ApiVersion = "0.9.4";

        /// <summary>
        /// Stable identifiers for the optional features this backend advertises.
        /// APPEND ONLY: never remove or rename an entry, or older clients that
        /// gate on it will silently lose the feature. The frontend keeps a
        /// matching baseline list of the capabilities that predate this
        /// endpoint, so an older backend (no /Public/capabilities) still lights
        /// up those baseline features.
        /// </summary>
        public static readonly IReadOnlyList<string> SupportedCapabilities = new List<string>
        {
            // Uploading a device image for a character portrait / singleImage
            // stat. Backed by POST /Image/streamimageupload, which predates this
            // endpoint, so it is also in the frontend baseline set.
            "character-image-upload",
        };

        private readonly IQueryProcessor _queryProcessor;

        public PublicController(IQueryProcessor queryProcessor)
        {
            _queryProcessor = queryProcessor;
        }

        /// <summary>
        /// Returns the minimal app version supported by this api.
        /// </summary>
        /// <param name="cancellationToken">cancellationToken</param>
        /// <returns>The minimal api version</returns>
        /// <response code="200">The minimal app version supported</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [HttpGet("getminimalversion")]
        public Task<ActionResult<string>> GetMinimalAppVersion(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<string>>(Ok(MinimalAppVersionSupported));
        }

        /// <summary>
        /// Advertises the optional features this backend supports so newer and
        /// older frontends/backends stay compatible. Purely additive; an older
        /// backend without this endpoint is treated by the client as
        /// "baseline capabilities only".
        /// </summary>
        /// <param name="cancellationToken">cancellationToken</param>
        /// <returns>The set of supported capabilities and the api version.</returns>
        /// <response code="200">The supported backend capabilities</response>
        [ProducesResponseType(typeof(BackendCapabilitiesDto), StatusCodes.Status200OK)]
        [HttpGet("capabilities")]
        public Task<ActionResult<BackendCapabilitiesDto>> GetCapabilities(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<BackendCapabilitiesDto>>(
                Ok(new BackendCapabilitiesDto { Capabilities = SupportedCapabilities, ApiVersion = ApiVersion })
            );
        }

        [HttpGet("getimage/{uuid}/{apikey}")]
        public async Task<IActionResult> GetImageFromUuidAndApiKey(
            [FromRoute] string uuid,
            [FromRoute] string apikey,
            CancellationToken cancellationToken
        )
        {
            if (!Guid.TryParse(uuid, out var parsedUuid))
            {
                return BadRequest("Could not parse uuid");
            }

            var imageMetaData = await new ImageMetaDataQuery
            {
                ModelId = ImageMetaData.ImageMetaDataIdentifier.From(parsedUuid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageMetaData.IsNone)
            {
                return BadRequest("Could not load imageMetaData");
            }

            if (imageMetaData.Get().ApiKey != apikey)
            {
                return BadRequest("Invalid API key provided.");
            }

            var streamForImage = await new ImageLoadQuery { MetaData = imageMetaData.Get() }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (streamForImage.IsNone)
            {
                return BadRequest("Could not load image");
            }

            return File(streamForImage.Get(), "image/" + imageMetaData.Get().ImageType.ToString().ToLower());
        }
    }
}
