using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.Fights;
using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    /// <summary>
    /// Persisted fights: the DM starts a fight, players roll initiative for their characters and companions,
    /// the DM keeps the order and ends the fight. A player who was away when the fight started fetches
    /// <c>current</c> on return and is asked to roll for whatever is still pending.
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class FightController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IFightService _fightService;
        private readonly IFightNotifier _fightNotifier;

        public FightController(IUserContext userContext, IFightService fightService, IFightNotifier fightNotifier)
        {
            _userContext = userContext;
            _fightService = fightService;
            _fightNotifier = fightNotifier;
        }

        private Guid CurrentUserId => _userContext.User.UserIdentifier.Value;

        /// <summary>
        /// The open fight of a campagne, as the caller may see it (DM: everything; player: own participants).
        /// </summary>
        /// <response code="200">The open fight, or <c>fight: null</c> if there is none</response>
        /// <response code="404">If the campagne does not exist or you are neither its DM nor a player in it</response>
        [ProducesResponseType(typeof(CurrentFightResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [HttpGet("current/{campagneid}")]
        public async Task<ActionResult<CurrentFightResponseDto>> GetCurrentFightAsync(
            Guid campagneid,
            CancellationToken cancellationToken
        )
        {
            var access = await _fightService.GetAccessAsync(campagneid, CurrentUserId, cancellationToken).ConfigureAwait(false);
            if (access == FightAccess.None)
            {
                return NotFound("Campagne not found.");
            }

            var fight = await _fightService.GetOpenFightAsync(campagneid, cancellationToken).ConfigureAwait(false);
            return Ok(
                new CurrentFightResponseDto
                {
                    Fight = fight == null ? null : FightDtoMapper.ToDto(fight, access, CurrentUserId),
                }
            );
        }

        /// <summary>
        /// DM starts a fight: every listed character and companion is asked to roll initiative - right away if
        /// its player is connected, otherwise when they come back. An open fight in the campagne ends.
        /// </summary>
        /// <response code="200">The new fight (DM view)</response>
        /// <response code="400">If a participant is not a character or companion of this campagne, or an enemy is invalid</response>
        /// <response code="403">If you are not the DM</response>
        /// <response code="404">If the campagne does not exist</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [HttpPost("start/{campagneid}")]
        public async Task<ActionResult<FightDto>> StartFightAsync(
            Guid campagneid,
            [FromBody] [Required] StartFightRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var result = await _fightService
                .StartAsync(
                    campagneid,
                    CurrentUserId,
                    requestedFightId: null,
                    request.Participants.Select(p => new FightParticipantRequest(p.CharacterUuid, p.PlayerCharacterId, p.Name)).ToList(),
                    (request.Enemies ?? new()).Select(e => new FightEnemyRequest(e.Name, e.Roll)).ToList(),
                    skipUnknownParticipants: false,
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (!result.Succeeded)
            {
                return ToErrorResult(result);
            }

            if (result.ReplacedFight != null)
            {
                await _fightNotifier.NotifyEndedAsync(result.ReplacedFight, CurrentUserId, cancellationToken).ConfigureAwait(false);
            }

            await _fightNotifier
                .NotifyStartedAsync(result.Fight!, CurrentUserId, includeLegacyAsk: true, cancellationToken)
                .ConfigureAwait(false);
            return Ok(FightDtoMapper.ToDmDto(result.Fight!));
        }

        /// <summary>
        /// Rolls initiative for your own pending characters and companions in this fight. The DM may roll for anyone.
        /// </summary>
        /// <response code="200">The fight as you may see it</response>
        /// <response code="400">If a roll names someone who is not in this fight, or is out of range</response>
        /// <response code="403">If you roll for someone else's character</response>
        /// <response code="404">If the fight does not exist or is not yours to see</response>
        /// <response code="409">If the fight is over, or a participant already rolled</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(string), StatusCodes.Status409Conflict)]
        [HttpPost("{fightid}/rolls")]
        public async Task<ActionResult<FightDto>> SubmitRollsAsync(
            Guid fightid,
            [FromBody] [Required] SubmitFightRollsRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var result = await _fightService
                .SubmitRollsAsync(
                    fightid,
                    CurrentUserId,
                    request.Rolls.Select(r => new FightRollRequest(r.CharacterUuid, r.Roll)).ToList(),
                    skipInvalidRolls: false,
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (!result.Succeeded)
            {
                return ToErrorResult(result);
            }

            await NotifyRolledAsync(result, cancellationToken).ConfigureAwait(false);
            return Ok(ToCallerDto(result.Fight!));
        }

        /// <summary>DM adds opponents with their rolls; each is placed in the order by its roll.</summary>
        /// <response code="200">The fight (DM view)</response>
        /// <response code="400">If an enemy has no name or the roll is out of range</response>
        /// <response code="403">If you are not the DM</response>
        /// <response code="404">If the fight does not exist</response>
        /// <response code="409">If the fight is over</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(string), StatusCodes.Status409Conflict)]
        [HttpPost("{fightid}/enemies")]
        public async Task<ActionResult<FightDto>> AddEnemiesAsync(
            Guid fightid,
            [FromBody] [Required] AddFightEnemiesRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var result = await _fightService
                .AddEnemiesAsync(
                    fightid,
                    CurrentUserId,
                    request.Enemies.Select(e => new FightEnemyRequest(e.Name, e.Roll)).ToList(),
                    cancellationToken
                )
                .ConfigureAwait(false);
            return result.Succeeded ? Ok(FightDtoMapper.ToDmDto(result.Fight!)) : ToErrorResult(result);
        }

        /// <summary>DM sets the initiative order of everyone who has a roll.</summary>
        /// <response code="200">The fight (DM view)</response>
        /// <response code="403">If you are not the DM</response>
        /// <response code="404">If the fight does not exist</response>
        /// <response code="409">If the fight is over, or the list does not match the participants with a roll</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(string), StatusCodes.Status409Conflict)]
        [HttpPut("{fightid}/order")]
        public async Task<ActionResult<FightDto>> ReorderAsync(
            Guid fightid,
            [FromBody] [Required] ReorderFightRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var result = await _fightService
                .ReorderAsync(fightid, CurrentUserId, request.ParticipantIds, cancellationToken)
                .ConfigureAwait(false);
            return result.Succeeded ? Ok(FightDtoMapper.ToDmDto(result.Fight!)) : ToErrorResult(result);
        }

        /// <summary>DM removes a participant. A pending character or companion is no longer asked to roll.</summary>
        /// <response code="200">The fight (DM view)</response>
        /// <response code="403">If you are not the DM</response>
        /// <response code="404">If the fight or participant does not exist</response>
        /// <response code="409">If the fight is over</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(string), StatusCodes.Status409Conflict)]
        [HttpDelete("{fightid}/participants/{participantid}")]
        public async Task<ActionResult<FightDto>> RemoveParticipantAsync(
            Guid fightid,
            Guid participantid,
            CancellationToken cancellationToken
        )
        {
            var result = await _fightService
                .RemoveParticipantAsync(fightid, CurrentUserId, participantid, cancellationToken)
                .ConfigureAwait(false);
            if (!result.Succeeded)
            {
                return ToErrorResult(result);
            }

            await _fightNotifier
                .NotifySettledAsync(result.Fight!, result.Removed.Where(p => p.IsPending), cancellationToken)
                .ConfigureAwait(false);
            return Ok(FightDtoMapper.ToDmDto(result.Fight!));
        }

        /// <summary>
        /// DM ends the fight. Nobody is asked to roll for it any more. Ending a fight that is already over is a no-op.
        /// </summary>
        /// <response code="200">The ended fight (DM view)</response>
        /// <response code="403">If you are not the DM</response>
        /// <response code="404">If the fight does not exist</response>
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(string), StatusCodes.Status404NotFound)]
        [HttpPost("{fightid}/end")]
        public async Task<ActionResult<FightDto>> EndFightAsync(Guid fightid, CancellationToken cancellationToken)
        {
            var result = await _fightService.EndAsync(fightid, CurrentUserId, cancellationToken).ConfigureAwait(false);
            if (!result.Succeeded)
            {
                return ToErrorResult(result);
            }

            if (result.Changed)
            {
                await _fightNotifier.NotifyEndedAsync(result.Fight!, CurrentUserId, cancellationToken).ConfigureAwait(false);
            }

            return Ok(FightDtoMapper.ToDmDto(result.Fight!));
        }

        private async Task NotifyRolledAsync(FightOperationResult result, CancellationToken cancellationToken)
        {
            if (!result.Changed)
            {
                return;
            }

            await _fightNotifier.NotifyUpdatedAsync(result.Fight!, CurrentUserId, cancellationToken).ConfigureAwait(false);
            await _fightNotifier.NotifySettledAsync(result.Fight!, result.Rolled, cancellationToken).ConfigureAwait(false);
            await _fightNotifier
                .NotifyLegacyRollsToDmAsync(result.Fight!, result.Rolled, cancellationToken)
                .ConfigureAwait(false);
        }

        private FightDto ToCallerDto(FightSnapshot fight) =>
            fight.DmUserId == CurrentUserId ? FightDtoMapper.ToDmDto(fight) : FightDtoMapper.ToPlayerDto(fight, CurrentUserId);

        private ActionResult ToErrorResult(FightOperationResult result) =>
            result.Error switch
            {
                FightError.NotFound => NotFound(result.Message),
                FightError.NotAllowed => StatusCode(StatusCodes.Status403Forbidden, result.Message),
                FightError.Ended or FightError.Conflict => Conflict(result.Message),
                _ => BadRequest(result.Message),
            };
    }
}
