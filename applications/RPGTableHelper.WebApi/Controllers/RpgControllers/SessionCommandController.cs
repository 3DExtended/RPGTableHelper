using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services.ConfigRevisions;
using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    /// <summary>
    /// sse-06: REST commands for table-session-scoped fight/roll signals and item grants
    /// (<c>AskPlayersForRolls</c> / <c>SendFightSequenceRollsToDm</c> /
    /// <c>SendGrantedItemsToPlayers</c>) as the sole path for clients. Rolls fan out an inline
    /// fight-sequence payload over SSE to session participants; grants mutate the character config through
    /// the same revisioned store used by sse-02/sse-04 and notify via <c>characterConfigChanged</c>.
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class SessionCommandController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISseEventHub _sseEventHub;
        private readonly ISessionPresenceService _sessionPresenceService;
        private readonly IConfigRevisionHistoryStore _configRevisionHistoryStore;
        private readonly IHostEnvironment _hostEnvironment;
        private readonly ILogger<SessionCommandController> _logger;

        public SessionCommandController(
            IUserContext userContext,
            IQueryProcessor queryProcessor,
            ISseEventHub sseEventHub,
            ISessionPresenceService sessionPresenceService,
            IConfigRevisionHistoryStore configRevisionHistoryStore,
            IHostEnvironment hostEnvironment,
            ILogger<SessionCommandController> logger
        )
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
            _sseEventHub = sseEventHub;
            _sessionPresenceService = sessionPresenceService;
            _configRevisionHistoryStore = configRevisionHistoryStore;
            _hostEnvironment = hostEnvironment;
            _logger = logger;
        }

        /// <summary>
        /// DM asks the other session participants to roll for fight order. Fans out the fight sequence
        /// inline over SSE (<c>playersAreAskedForRolls</c>) to other users currently in the table session -
        /// no ephemeral state is persisted server-side.
        /// </summary>
        /// <response code="200">Notify was sent (or no-op if nobody else is currently in session)</response>
        /// <response code="400">If the campagneid is invalid</response>
        /// <response code="401">If you are not logged in or not the dm of this campagne</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("askplayersforrolls/{campagneid}")]
        public async Task<IActionResult> AskPlayersForRollsAsync(
            string campagneid,
            [FromBody] [Required] FightSequenceDto fightSequence,
            CancellationToken cancellationToken
        )
        {
            if (string.IsNullOrWhiteSpace(campagneid) || !Guid.TryParse(campagneid, out var campagneIdParsed))
            {
                return BadRequest("No valid campagneId passed");
            }

            var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(campagneIdParsed) }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
            {
                return Unauthorized();
            }

            var actorUserId = _userContext.User.UserIdentifier.Value;
            var recipients = _sessionPresenceService
                .GetOnlineParticipants(campagneIdParsed)
                .Where(id => id != actorUserId)
                .ToList();

            if (recipients.Count > 0)
            {
                var payload = JsonSerializer.Serialize(fightSequence, ConfigDocumentPatcher.SerializerOptions);
                await _sseEventHub
                    .SendToUsersAsync(recipients, "playersAreAskedForRolls", payload, cancellationToken)
                    .ConfigureAwait(false);
            }

            return Ok();
        }

        /// <summary>
        /// A player reports their fight-order roll(s) back to the DM. Notifies the DM inline over SSE
        /// (<c>dmReceivedFightSequenceAnswer</c>) if the DM currently has an active table session for this
        /// character's campagne; no-op otherwise.
        /// </summary>
        /// <response code="200">Notify was sent (or no-op if the DM is not currently in session)</response>
        /// <response code="400">If the playercharacterid is invalid, or the character has no campagne</response>
        /// <response code="401">If you are not logged in or do not own this character</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("sendfightsequencerollstodm/{playercharacterid}")]
        public async Task<IActionResult> SendFightSequenceRollsToDmAsync(
            string playercharacterid,
            [FromBody] [Required] FightSequenceDto fightSequence,
            CancellationToken cancellationToken
        )
        {
            if (
                string.IsNullOrWhiteSpace(playercharacterid)
                || !Guid.TryParse(playercharacterid, out var playerCharacterIdParsed)
            )
            {
                return BadRequest("No valid playercharacterid passed");
            }

            var playerCharacter = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(playerCharacterIdParsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacter.IsNone || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier)
            {
                return Unauthorized();
            }

            if (playerCharacter.Get().CampagneId == null)
            {
                return BadRequest("Character is not assigned to a campagne");
            }

            var campagne = await new CampagneQuery { ModelId = playerCharacter.Get().CampagneId! }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone)
            {
                return BadRequest("Could not load campagne");
            }

            var dmUserId = campagne.Get().DmUserId.Value;
            if (_sessionPresenceService.IsOnline(campagne.Get().Id.Value, dmUserId))
            {
                var payload = JsonSerializer.Serialize(fightSequence, ConfigDocumentPatcher.SerializerOptions);
                await _sseEventHub
                    .SendToUserAsync(dmUserId, "dmReceivedFightSequenceAnswer", payload, cancellationToken)
                    .ConfigureAwait(false);
            }

            return Ok();
        }

        /// <summary>
        /// DM grants items to a player character. Additively merges the grants into the character's
        /// <c>inventory</c> through the same revisioned config store used by sse-02/sse-04 (bumping the
        /// revision, recording a history snapshot, and writing a file backup), then notifies session
        /// participants via <c>characterConfigChanged</c> and the granted player (if online in session) via
        /// a small <c>itemsGranted</c> toast event carrying the grant details.
        /// </summary>
        /// <response code="200">The revision after this write</response>
        /// <response code="400">If the playercharacterid is invalid, or the character has no campagne</response>
        /// <response code="401">If you are not logged in or not the dm of this character's campagne</response>
        [ProducesResponseType(typeof(ConfigWriteResultDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("grantitems/{playercharacterid}")]
        public async Task<ActionResult<ConfigWriteResultDto>> GrantItemsAsync(
            string playercharacterid,
            [FromBody] [Required] GrantItemsRequestDto grantRequest,
            CancellationToken cancellationToken
        )
        {
            if (
                string.IsNullOrWhiteSpace(playercharacterid)
                || !Guid.TryParse(playercharacterid, out var playerCharacterIdParsed)
            )
            {
                return BadRequest("No valid playercharacterid passed");
            }

            var playerCharacter = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(playerCharacterIdParsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacter.IsNone || playerCharacter.Get().CampagneId == null)
            {
                return BadRequest("Could not verify character or its campagne");
            }

            var campagne = await new CampagneQuery { ModelId = playerCharacter.Get().CampagneId! }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
            {
                return Unauthorized();
            }

            var updated = playerCharacter.Get();
            var currentRevision = updated.RpgCharacterConfigurationRevision;
            var newRevision = currentRevision + 1;
            var resultJson = CharacterInventoryPatcher.ApplyGrants(updated.RpgCharacterConfiguration, grantRequest.Items);

            updated.RpgCharacterConfiguration = resultJson;
            updated.RpgCharacterConfigurationRevision = newRevision;

            var updateResult = await new PlayerCharacterUpdateQuery { UpdatedModel = updated }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (updateResult.IsNone)
            {
                return BadRequest("Could not update player character configuration");
            }

            await _configRevisionHistoryStore
                .RecordPlayerCharacterSnapshotAsync(playerCharacterIdParsed, newRevision, resultJson, cancellationToken)
                .ConfigureAwait(false);

            var timestamp = DateTime.Now.ToString("yyyyMMdd-HHmm");
            await ConfigFileBackupWriter
                .WriteBackupAsync(
                    _hostEnvironment,
                    _logger,
                    $"{updated.CharacterName}-{playerCharacterIdParsed}-{timestamp}-rpgbackup.json",
                    resultJson,
                    cancellationToken
                )
                .ConfigureAwait(false);

            await NotifyCharacterConfigChangedAsync(playerCharacterIdParsed, campagne.Get().Id, newRevision, cancellationToken)
                .ConfigureAwait(false);

            await NotifyItemsGrantedAsync(
                    campagne.Get().Id.Value,
                    updated.PlayerUserId.Value,
                    playerCharacterIdParsed,
                    grantRequest.Items,
                    cancellationToken
                )
                .ConfigureAwait(false);

            return Ok(new ConfigWriteResultDto { Revision = newRevision });
        }

        /// <summary>
        /// Emits a session-scoped <c>characterConfigChanged</c> SSE notify (<c>{ id, revision }</c> only, no
        /// body) to the other users currently in the owning campagne's table session, mirroring
        /// <see cref="PlayerCharacterController"/>'s write paths so peers catch up the same way regardless of
        /// which endpoint performed the write.
        /// </summary>
        private Task NotifyCharacterConfigChangedAsync(
            Guid playerCharacterId,
            Campagne.CampagneIdentifier campagneId,
            int revision,
            CancellationToken cancellationToken
        )
        {
            var actorUserId = _userContext.User.UserIdentifier.Value;
            var recipients = _sessionPresenceService
                .GetOnlineParticipants(campagneId.Value)
                .Where(id => id != actorUserId)
                .ToList();

            if (recipients.Count == 0)
            {
                return Task.CompletedTask;
            }

            var payload = JsonSerializer.Serialize(new { id = playerCharacterId.ToString(), revision });
            return _sseEventHub.SendToUsersAsync(recipients, "characterConfigChanged", payload, cancellationToken);
        }

        /// <summary>
        /// Optional tiny toast notify (sse-06) straight to the granted player - carrying the grant details
        /// (unlike <c>characterConfigChanged</c>) so the client can show "you received X" without a GET
        /// round-trip. Session-scoped: no-op if the player is not currently online in this table session.
        /// </summary>
        private Task NotifyItemsGrantedAsync(
            Guid campagneId,
            Guid playerUserId,
            Guid playerCharacterId,
            IReadOnlyList<GrantedItemDto> items,
            CancellationToken cancellationToken
        )
        {
            if (!_sessionPresenceService.IsOnline(campagneId, playerUserId))
            {
                return Task.CompletedTask;
            }

            var payload = JsonSerializer.Serialize(
                new
                {
                    playerCharacterId = playerCharacterId.ToString(),
                    items = items.Select(i => new { itemUuid = i.ItemUuid, amount = i.Amount }),
                }
            );

            return _sseEventHub.SendToUserAsync(playerUserId, "itemsGranted", payload, cancellationToken);
        }
    }
}
