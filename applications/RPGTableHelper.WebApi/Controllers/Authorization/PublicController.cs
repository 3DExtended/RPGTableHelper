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
