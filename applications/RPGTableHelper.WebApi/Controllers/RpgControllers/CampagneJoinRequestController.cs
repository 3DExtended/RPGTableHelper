using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class CampagneJoinRequestController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;

        public CampagneJoinRequestController(IUserContext userContext, IQueryProcessor queryProcessor)
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
        }

        /// <summary>
        /// Creates a new campagneJoinRequest with the calling user as dm.
        /// </summary>
        /// <param name="createDto">The creation details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the id of the created campagneJoinRequest.</returns>
        /// <response code="200">The id of the newly created campagneJoinRequest</response>
        /// <response code="400">If the data provided is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(CampagneJoinRequest.CampagneJoinRequestIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createcampagneJoinRequest")]
        public async Task<
            ActionResult<CampagneJoinRequest.CampagneJoinRequestIdentifier>
        > CreateNewCampagneJoinRequestAsync(
            [FromBody] CampagneJoinRequestCreateDto createDto,
            CancellationToken cancellationToken
        )
        {
            if (
                createDto == null
                || string.IsNullOrWhiteSpace(createDto.CampagneId)
                || string.IsNullOrWhiteSpace(createDto.PlayerCharacterId)
            )
            {
                return BadRequest("Missing createDto");
            }

            var campagneJoinRequestId = await new CampagneJoinRequestCreateQuery
            {
                ModelToCreate = new CampagneJoinRequest
                {
                    Id = CampagneJoinRequest.CampagneJoinRequestIdentifier.From(Guid.Empty),
                    CampagneId = Campagne.CampagneIdentifier.From(Guid.Parse(createDto.CampagneId)),
                    PlayerId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(createDto.PlayerCharacterId)),
                    UserId = _userContext.User.UserIdentifier,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagneJoinRequestId.IsNone)
            {
                return BadRequest("Could not create new campagneJoinRequest");
            }

            return Ok(campagneJoinRequestId.Get());
        }

        /// <summary>
        /// Accepts or denies a campagneJoinRequest with the calling user as dm.
        /// </summary>
        /// <param name="handleJoinRequestDto">The handle details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Ok if everything worked</returns>
        /// <response code="200">The id of the newly created campagneJoinRequest</response>
        /// <response code="400">If the data provided is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("handlejoinrequest")]
        public async Task<IActionResult> HandleCampagneJoinRequest(
            [FromBody] HandleJoinRequestDto handleJoinRequestDto,
            CancellationToken cancellationToken
        )
        {
            if (handleJoinRequestDto == null || handleJoinRequestDto.CampagneJoinRequestId == null)
            {
                return BadRequest("Invalid handle Dto");
            }

            // load join request
            var joinRequest = await new CampagneJoinRequestQuery
            {
                ModelId = CampagneJoinRequest.CampagneJoinRequestIdentifier.From(
                    Guid.Parse(handleJoinRequestDto.CampagneJoinRequestId)
                ),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (joinRequest.IsNone)
            {
                return BadRequest("Invalid CampagneJoinRequestIdentifier");
            }

            // load correct campagne
            var campagne = await new CampagneQuery { ModelId = joinRequest.Get().CampagneId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
            {
                return BadRequest("Could not validate campagne");
            }

            var player = await new PlayerCharacterQuery { ModelId = joinRequest.Get().PlayerId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (player.IsNone)
            {
                return BadRequest("Could not validate player");
            }

            if (handleJoinRequestDto.Type == HandleJoinRequestType.Accept && player.Get().CampagneId != null)
            {
                var playerToUpdate = player.Get();
                playerToUpdate.CampagneId = campagne.Get().Id;

                var updateResult = await new PlayerCharacterUpdateQuery { UpdatedModel = playerToUpdate }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (updateResult.IsNone)
                {
                    return BadRequest("Could not update player");
                }
            }

            var deleteRequestResult = await new CampagneJoinRequestDeleteQuery { Id = joinRequest.Get().Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (deleteRequestResult.IsNone)
            {
                return BadRequest("Could not delete CampagneJoinRequest (but updated player).");
            }

            return Ok();
        }

        /// <summary>
        /// Returns a list of campagneJoinRequests for a campagne this user is the dm of.
        /// </summary>
        /// <param name="campagneId">campagneId</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of campagneJoinRequests.</returns>
        /// <response code="200">A list of all campagneJoinRequests for this user as dm</response>
        /// <response code="400">If there was an error retrieving the campagneJoinRequests</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(IReadOnlyList<JoinRequestForCampagneDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getcampagneJoinRequests/{campagneId}")]
        public async Task<
            ActionResult<IReadOnlyList<JoinRequestForCampagneDto>>
        > GetCampagneJoinRequestsForUserAsDmAsync([FromRoute] string campagneId, CancellationToken cancellationToken)
        {
            var campagne = await new CampagneQuery
            {
                ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
            {
                return BadRequest("Could not load campagne or you are not dm");
            }

            var campagneJoinRequests = await new CampagneJoinRequestsForCampagneQuery
            {
                CampagneId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagneJoinRequests.IsNone)
            {
                return BadRequest("Could not retrieve campagneJoinRequests.");
            }

            return Ok(
                campagneJoinRequests
                    .Get()
                    .Select(r => new JoinRequestForCampagneDto
                    {
                        PlayerCharacter = r.playerCharacter,
                        Request = r.request,
                        Username = r.username,
                    })
                    .ToList()
            );
        }
    }
}
