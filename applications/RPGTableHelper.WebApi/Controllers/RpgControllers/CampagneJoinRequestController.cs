using System.ComponentModel.DataAnnotations;
using System.Text.Json;
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
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class CampagneJoinRequestController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISseEventHub _sseEventHub;

        public CampagneJoinRequestController(
            IUserContext userContext,
            IQueryProcessor queryProcessor,
            ISseEventHub sseEventHub
        )
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
            _sseEventHub = sseEventHub;
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
            [FromBody] [Required] CampagneJoinRequestCreateDto createDto,
            CancellationToken cancellationToken
        )
        {
            if (
                createDto == null
                || string.IsNullOrWhiteSpace(createDto.CampagneJoinCode)
                || string.IsNullOrWhiteSpace(createDto.PlayerCharacterId)
            )
            {
                return BadRequest("Missing createDto");
            }

            var playerCharacter = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(createDto.PlayerCharacterId)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacter.IsNone || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier)
            {
                return BadRequest("Could not verify player character");
            }

            var campagneForJoinCode = await new CampagneByJoinCodeQuery { JoinCode = createDto.CampagneJoinCode }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagneForJoinCode.IsNone)
            {
                return BadRequest("Could not find campagne for join code");
            }

            var campagneJoinRequestId = await new CampagneJoinRequestCreateQuery
            {
                ModelToCreate = new CampagneJoinRequest
                {
                    Id = CampagneJoinRequest.CampagneJoinRequestIdentifier.From(Guid.Empty),
                    CampagneId = campagneForJoinCode.Get().Id,
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

            await NotifyJoinRequestCreatedAsync(
                    campagneForJoinCode.Get(),
                    campagneJoinRequestId.Get(),
                    playerCharacter.Get(),
                    cancellationToken
                )
                .ConfigureAwait(false);

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
            [FromBody] [Required] HandleJoinRequestDto handleJoinRequestDto,
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

            if (handleJoinRequestDto.Type == HandleJoinRequestType.Accept && player.Get().CampagneId == null)
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

            await NotifyJoinRequestResolvedAsync(
                    joinRequest.Get(),
                    campagne.Get(),
                    handleJoinRequestDto.Type,
                    cancellationToken
                )
                .ConfigureAwait(false);

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

        /// <summary>
        /// Emits a membership-scoped <c>joinRequestCreated</c> SSE notify to the campagne's DM, whenever
        /// their <c>/events</c> stream is up. Not gated on table session presence (join-request management
        /// works from the app shell, see PRD user story 29).
        /// </summary>
        private Task NotifyJoinRequestCreatedAsync(
            Campagne campagne,
            CampagneJoinRequest.CampagneJoinRequestIdentifier campagneJoinRequestId,
            PlayerCharacter playerCharacter,
            CancellationToken cancellationToken
        )
        {
            var payload = JsonSerializer.Serialize(
                new
                {
                    requestId = campagneJoinRequestId.Value.ToString(),
                    campagneId = campagne.Id.Value.ToString(),
                    playerCharacterId = playerCharacter.Id.Value.ToString(),
                    playerName = playerCharacter.CharacterName,
                    username = _userContext.User.Username,
                }
            );

            return _sseEventHub.SendToUserAsync(
                campagne.DmUserId.Value,
                "joinRequestCreated",
                payload,
                cancellationToken
            );
        }

        /// <summary>
        /// Emits a membership-scoped <c>joinRequestResolved</c> SSE notify to the requesting player, whenever
        /// their <c>/events</c> stream is up. Not gated on table session presence.
        /// </summary>
        private Task NotifyJoinRequestResolvedAsync(
            CampagneJoinRequest joinRequest,
            Campagne campagne,
            HandleJoinRequestType type,
            CancellationToken cancellationToken
        )
        {
            var payload = JsonSerializer.Serialize(
                new
                {
                    requestId = joinRequest.Id.Value.ToString(),
                    campagneId = campagne.Id.Value.ToString(),
                    type = type.ToString(),
                }
            );

            return _sseEventHub.SendToUserAsync(
                joinRequest.UserId.Value,
                "joinRequestResolved",
                payload,
                cancellationToken
            );
        }
    }
}
