using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services.Auth;
using RPGTableHelper.WebApi.Services.Presence;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// The key's owner, who sits at a campaign's table, the campaign's rules, and being present at the table.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.V1)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalTableController : ExternalApiControllerBase
    {
        private readonly ISessionPresenceService _sessionPresenceService;

        public ExternalTableController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            ISessionPresenceService sessionPresenceService
        )
            : base(queryProcessor, userContext)
        {
            _sessionPresenceService = sessionPresenceService;
        }

        /// <summary>
        /// Who the API key belongs to and which scopes it has. Needs no scope, so it is a good first call.
        /// </summary>
        /// <response code="200">The key's owner and permissions</response>
        [ProducesResponseType(typeof(ExternalMeDto), StatusCodes.Status200OK)]
        [HttpGet("me")]
        public async Task<ActionResult<ExternalMeDto>> GetMeAsync(CancellationToken cancellationToken)
        {
            var user = await new UserQuery { ModelId = UserContext.User.UserIdentifier }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);

            return Ok(
                new ExternalMeDto
                {
                    UserId = CurrentUserId,
                    Username = user.IsSome ? user.Get().Username : UserContext.User.Username ?? string.Empty,
                    ApiKey = new ExternalApiKeyInfoDto
                    {
                        Prefix = User.FindFirst(ApiKeyClaimTypes.ApiKeyPrefix)?.Value ?? string.Empty,
                        Scopes = User.GetApiKeyScopes().ToList(),
                    },
                }
            );
        }

        /// <summary>
        /// Everyone at the campaign's table: the DM and each player with their characters. Use the user ids for a
        /// note block's <c>visibleTo</c>.
        /// </summary>
        /// <response code="200">The DM first, then the players</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.CampaignsRead)]
        [ProducesResponseType(typeof(List<ExternalCampaignMemberDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("campaigns/{campaignId:guid}/members")]
        public async Task<ActionResult<List<ExternalCampaignMemberDto>>> GetMembersAsync(
            Guid campaignId,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("Campaign not found.");
            }

            var characters = await new PlayerCharactersForCampagneQuery { CampagneId = campaign.Id }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);

            var members = new List<ExternalCampaignMemberDto>
            {
                new()
                {
                    UserId = campaign.DmUserId.Value,
                    IsDm = true,
                    IsYou = campaign.DmUserId.Value == CurrentUserId,
                },
            };
            members.AddRange(
                (characters.IsSome ? characters.Get() : new List<DataLayer.Contracts.Models.RpgEntities.PlayerCharacter>())
                    .Where(c => c.PlayerUserId.Value != campaign.DmUserId.Value)
                    .GroupBy(c => c.PlayerUserId.Value)
                    .Select(player => new ExternalCampaignMemberDto
                    {
                        UserId = player.Key,
                        IsDm = false,
                        IsYou = player.Key == CurrentUserId,
                        Characters = player
                            .OrderBy(c => c.CharacterName, StringComparer.CurrentCultureIgnoreCase)
                            .Select(c => new ExternalCharacterRefDto { Id = c.Id.Value, Name = c.CharacterName })
                            .ToList(),
                    })
            );

            return Ok(members);
        }

        /// <summary>
        /// The campaign's rule configuration. A sheet's <c>characterStats</c> only make sense with it: each stat's
        /// <c>statUuid</c> points into <c>characterStatTabsDefinition</c>, which names the stat and its value type.
        /// </summary>
        /// <response code="200">The configuration and its revision</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.CampaignsRead)]
        [ProducesResponseType(typeof(ExternalCampaignConfigDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("campaigns/{campaignId:guid}/config")]
        public async Task<ActionResult<ExternalCampaignConfigDto>> GetConfigAsync(
            Guid campaignId,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("Campaign not found.");
            }

            return Ok(
                new ExternalCampaignConfigDto
                {
                    CampaignId = campaignId,
                    Revision = campaign.RpgConfigurationMergedRevision,
                    Config = ExternalJson.ParseStored(campaign.RpgConfiguration),
                }
            );
        }

        /// <summary>
        /// Sits you down at the campaign's table: the others see you as online, and you receive the table's events
        /// (initiative requests, sheet changes, ...) on your open <c>/events</c> stream. Open the stream first.
        /// </summary>
        /// <response code="200">You are at the table; the body lists everyone who is</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.Events)]
        [ProducesResponseType(typeof(SessionEnterResultDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("campaigns/{campaignId:guid}/session/enter")]
        public async Task<ActionResult<SessionEnterResultDto>> EnterSessionAsync(
            Guid campaignId,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("Campaign not found.");
            }

            await _sessionPresenceService.EnterAsync(campaignId, CurrentUserId, cancellationToken).ConfigureAwait(false);
            return Ok(
                new SessionEnterResultDto
                {
                    OnlineUserIds = _sessionPresenceService
                        .GetOnlineParticipants(campaignId)
                        .Select(id => id.ToString())
                        .ToList(),
                }
            );
        }

        /// <summary>
        /// Leaves the campaign's table. This also marks you offline if you sit at the same table in the
        /// Questkeeper app, because presence is per user, not per device.
        /// </summary>
        /// <response code="204">You left the table</response>
        [RequireScope(ApiKeyScopes.Events)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [HttpPost("campaigns/{campaignId:guid}/session/leave")]
        public async Task<IActionResult> LeaveSessionAsync(Guid campaignId, CancellationToken cancellationToken)
        {
            await _sessionPresenceService.LeaveAsync(campaignId, CurrentUserId, cancellationToken).ConfigureAwait(false);
            return NoContent();
        }
    }
}
