using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class CampagneController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;

        public CampagneController(IUserContext userContext, IQueryProcessor queryProcessor)
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
        }

        /// <summary>
        /// Creates a new campagne with the calling user as dm.
        /// </summary>
        /// <param name="createDto">The creation details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the id of the created campagne.</returns>
        /// <response code="200">The id of the newly created campagne</response>
        /// <response code="400">If the data provided is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(Campagne.CampagneIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createcampagne")]
        public async Task<ActionResult<Campagne.CampagneIdentifier>> CreateNewCampagneAsync(
            [FromBody] CampagneCreateDto createDto,
            CancellationToken cancellationToken
        )
        {
            if (createDto == null || string.IsNullOrWhiteSpace(createDto.CampagneName))
            {
                return BadRequest("Missing createDto");
            }

            var newJoinCode = await new CampagneNewJoinCodeQuery()
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (newJoinCode.IsNone)
            {
                return BadRequest("Could not generate new join code.");
            }

            var campagneId = await new CampagneCreateQuery
            {
                ModelToCreate = new Campagne
                {
                    Id = Campagne.CampagneIdentifier.From(Guid.Empty),
                    JoinCode = newJoinCode.Get(),
                    CampagneName = createDto.CampagneName,
                    DmUserId = _userContext.User.UserIdentifier,
                    RpgConfiguration = createDto.RpgConfiguration.ToOption(),
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagneId.IsNone)
            {
                return BadRequest("Could not create new campagne");
            }

            return Ok(campagneId.Get().Value);
        }

        /// <summary>
        /// Returns a list of campagnes this user is the dm of.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of campagnes.</returns>
        /// <response code="200">The id of the newly created campagne</response>
        /// <response code="400">If there was an error retrieving the campagnes</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(IReadOnlyList<Campagne>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getcampagnes")]
        public async Task<ActionResult<IReadOnlyList<Campagne>>> GetCampagnesForUserAsDmAsync(
            CancellationToken cancellationToken
        )
        {
            var campagnes = await new CampagnesForUserAsDmQuery
            {
                UserId = _userContext.User.UserIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagnes.IsNone)
            {
                return BadRequest("Could not retrieve campagnes.");
            }

            return Ok(campagnes.Get());
        }
    }
}
