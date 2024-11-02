using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
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
    }
}
