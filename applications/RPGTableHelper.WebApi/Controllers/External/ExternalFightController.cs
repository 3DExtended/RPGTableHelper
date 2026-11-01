using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Dtos.Fights;
using RPGTableHelper.WebApi.Services.Auth;
using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Initiative as a player: see whether the DM started a fight and roll for your characters and companions.
    /// The fight is stored, so a client that was away simply asks again; nothing is lost while it is offline.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.V1)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalFightController : ExternalApiControllerBase
    {
        private readonly IFightService _fightService;
        private readonly IFightNotifier _fightNotifier;

        public ExternalFightController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            IFightService fightService,
            IFightNotifier fightNotifier
        )
            : base(queryProcessor, userContext)
        {
            _fightService = fightService;
            _fightNotifier = fightNotifier;
        }

        /// <summary>
        /// The campaign's open fight as a player sees it: only your own characters and companions, with
        /// <c>isPending</c> set for those you still have to roll for. <c>fight</c> is null if there is no fight.
        /// Even the DM gets the player view here.
        /// </summary>
        /// <response code="200">The open fight, or <c>fight: null</c></response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.FightsPlay)]
        [ProducesResponseType(typeof(CurrentFightResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("campaigns/{campaignId:guid}/fight")]
        public async Task<ActionResult<CurrentFightResponseDto>> GetFightAsync(
            Guid campaignId,
            CancellationToken cancellationToken
        )
        {
            var access = await _fightService.GetAccessAsync(campaignId, CurrentUserId, cancellationToken).ConfigureAwait(false);
            if (access == FightAccess.None)
            {
                return NotFoundError("Campaign not found.");
            }

            var fight = await _fightService.GetOpenFightAsync(campaignId, cancellationToken).ConfigureAwait(false);
            return Ok(
                new CurrentFightResponseDto
                {
                    Fight = fight == null ? null : FightDtoMapper.ToPlayerDto(fight, CurrentUserId),
                }
            );
        }

        /// <summary>
        /// Rolls initiative for your pending characters and companions in the open fight. Send the total with all
        /// modifiers; the DM sees the new order right away.
        /// </summary>
        /// <response code="200">The fight as you see it now</response>
        /// <response code="400">If a roll names someone who is not in the fight, or is out of range</response>
        /// <response code="403">If you roll for someone else's character (<c>forbidden</c>)</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        /// <response code="409">If there is no open fight (<c>no_open_fight</c>) or you already rolled (<c>fight_conflict</c>)</response>
        [RequireScope(ApiKeyScopes.FightsPlay)]
        [ProducesResponseType(typeof(FightDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpPost("campaigns/{campaignId:guid}/fight/rolls")]
        public async Task<ActionResult<FightDto>> SubmitRollsAsync(
            Guid campaignId,
            [FromBody] [Required] SubmitFightRollsRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var access = await _fightService.GetAccessAsync(campaignId, CurrentUserId, cancellationToken).ConfigureAwait(false);
            if (access == FightAccess.None)
            {
                return NotFoundError("Campaign not found.");
            }

            var fight = await _fightService.GetOpenFightAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (fight == null)
            {
                return Error(StatusCodes.Status409Conflict, ExternalApiErrors.NoOpenFight, "There is no open fight in this campaign.");
            }

            // The DM may roll for anyone in the app; through the player API everyone rolls only for their own.
            var foreign = request
                .Rolls.Where(roll =>
                    fight.Participants.Any(p => p.CharacterUuid == roll.CharacterUuid && p.OwnerUserId != CurrentUserId)
                )
                .Select(roll => roll.CharacterUuid)
                .ToList();
            if (foreign.Count > 0)
            {
                return Error(
                    StatusCodes.Status403Forbidden,
                    ExternalApiErrors.Forbidden,
                    $"You can only roll for your own characters and companions, not for {string.Join(", ", foreign)}."
                );
            }

            var result = await _fightService
                .SubmitRollsAsync(
                    fight.Id,
                    CurrentUserId,
                    request.Rolls.Select(r => new FightRollRequest(r.CharacterUuid, r.Roll)).ToList(),
                    skipInvalidRolls: false,
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (!result.Succeeded)
            {
                return result.Error switch
                {
                    FightError.NotFound or FightError.Ended => Error(
                        StatusCodes.Status409Conflict,
                        ExternalApiErrors.NoOpenFight,
                        result.Message ?? "The fight is over."
                    ),
                    FightError.NotAllowed => Error(
                        StatusCodes.Status403Forbidden,
                        ExternalApiErrors.Forbidden,
                        result.Message ?? "You may not roll for this."
                    ),
                    FightError.Conflict => Error(
                        StatusCodes.Status409Conflict,
                        ExternalApiErrors.FightConflict,
                        result.Message ?? "The fight changed."
                    ),
                    _ => InvalidRequest(result.Message ?? "The rolls are not valid."),
                };
            }

            if (result.Changed)
            {
                await _fightNotifier.NotifyUpdatedAsync(result.Fight!, CurrentUserId, cancellationToken).ConfigureAwait(false);
                await _fightNotifier
                    .NotifySettledAsync(result.Fight!, result.Rolled, cancellationToken)
                    .ConfigureAwait(false);
                await _fightNotifier
                    .NotifyLegacyRollsToDmAsync(result.Fight!, result.Rolled, cancellationToken)
                    .ConfigureAwait(false);
            }

            return Ok(FightDtoMapper.ToPlayerDto(result.Fight!, CurrentUserId));
        }
    }
}
