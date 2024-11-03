using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("/[controller]")]
    public class PublicController : ControllerBase
    {
        public static readonly string MinimalAppVersionSupported = "1.0.0";
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

        // TODO remove me
        [HttpPost("createimage")]
        public async Task<IActionResult> CreateImage([FromQuery] string prompt, CancellationToken cancellationToken)
        {
            var imageGenerationResult = await new AiGenerateImageQuery { ImagePrompt = prompt }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageGenerationResult.IsNone)
            {
                return BadRequest();
            }

            return File(imageGenerationResult.Get(), "image/png");
        }

        [HttpGet("getimage/{uuid}/{apikey}")]
        public async Task<IActionResult> GetImageFromUuidAndApiKey(
            [FromRoute] string uuid,
            [FromRoute] string apikey,
            CancellationToken cancellationToken
        )
        {
            var imageMetaData = await new ImageMetaDataQuery
            {
                ModelId = ImageMetaData.ImageMetaDataIdentifier.From(Guid.Parse(uuid)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageMetaData.IsNone)
            {
                return BadRequest();
            }

            if (imageMetaData.Get().ApiKey != apikey)
            {
                return BadRequest();
            }

            var streamForImage = await new ImageLoadQuery { MetaData = imageMetaData.Get() }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (streamForImage.IsNone)
            {
                return BadRequest();
            }

            return File(streamForImage.Get(), "image/" + imageMetaData.Get().ImageType.ToString().ToLower());
        }
    }
}
