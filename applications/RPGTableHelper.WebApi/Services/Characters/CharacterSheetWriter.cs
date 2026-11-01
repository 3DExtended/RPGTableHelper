using System.Text.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.WebApi.Services.ConfigRevisions;
using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Services.Characters;

public enum CharacterSheetWriteStatus
{
    Saved,

    /// <summary>The character does not exist or does not belong to the caller.</summary>
    NotFound,

    /// <summary>The sheet changed since the revision the patch was computed against.</summary>
    Conflict,

    /// <summary>The patch is not a valid JSON Patch or does not apply to the sheet.</summary>
    InvalidPatch,

    /// <summary>The patched sheet would no longer be a valid sheet; nothing was saved.</summary>
    InvalidSheet,

    Failed,
}

public sealed class CharacterSheetWriteResult
{
    public CharacterSheetWriteStatus Status { get; init; }

    /// <summary>The revision after the write, or the current revision on <see cref="CharacterSheetWriteStatus.Conflict"/>.</summary>
    public int Revision { get; init; }

    public string? Message { get; init; }

    public IReadOnlyList<string> Problems { get; init; } = Array.Empty<string>();
}

public interface ICharacterSheetWriter
{
    /// <summary>
    /// Applies an RFC 6902 JSON Patch to a character sheet the actor owns, if the sheet is still at
    /// <paramref name="fromRevision"/>. Stores the new revision, keeps it in the revision history and tells the
    /// other people at the table (<c>characterConfigChanged</c>). With <paramref name="validate"/> a patch that
    /// would leave the sheet unreadable for the app is rejected.
    /// </summary>
    /// <param name="playerCharacterId">The character whose sheet changes.</param>
    /// <param name="actorUserId">Who writes; must own the character.</param>
    /// <param name="fromRevision">The revision the patch was computed against.</param>
    /// <param name="patchJson">The JSON Patch document as a JSON array string.</param>
    /// <param name="validate">Reject patches that leave the sheet invalid (see <see cref="CharacterSheetValidator"/>).</param>
    /// <param name="source">Who wrote, for the log (e.g. the API key prefix); null for the app.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    Task<CharacterSheetWriteResult> PatchAsync(
        Guid playerCharacterId,
        Guid actorUserId,
        int fromRevision,
        string patchJson,
        bool validate,
        string? source,
        CancellationToken cancellationToken
    );
}

public sealed class CharacterSheetWriter : ICharacterSheetWriter
{
    private readonly IQueryProcessor _queryProcessor;
    private readonly IConfigRevisionHistoryStore _configRevisionHistoryStore;
    private readonly IHostEnvironment _hostEnvironment;
    private readonly ILogger<CharacterSheetWriter> _logger;
    private readonly ISseEventHub _sseEventHub;
    private readonly ISessionPresenceService _sessionPresenceService;

    public CharacterSheetWriter(
        IQueryProcessor queryProcessor,
        IConfigRevisionHistoryStore configRevisionHistoryStore,
        IHostEnvironment hostEnvironment,
        ILogger<CharacterSheetWriter> logger,
        ISseEventHub sseEventHub,
        ISessionPresenceService sessionPresenceService
    )
    {
        _queryProcessor = queryProcessor;
        _configRevisionHistoryStore = configRevisionHistoryStore;
        _hostEnvironment = hostEnvironment;
        _logger = logger;
        _sseEventHub = sseEventHub;
        _sessionPresenceService = sessionPresenceService;
    }

    public async Task<CharacterSheetWriteResult> PatchAsync(
        Guid playerCharacterId,
        Guid actorUserId,
        int fromRevision,
        string patchJson,
        bool validate,
        string? source,
        CancellationToken cancellationToken
    )
    {
        var playerCharacter = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(playerCharacterId),
        }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (playerCharacter.IsNone || playerCharacter.Get().PlayerUserId.Value != actorUserId)
        {
            return new CharacterSheetWriteResult { Status = CharacterSheetWriteStatus.NotFound };
        }

        var updated = playerCharacter.Get();
        var currentRevision = updated.RpgCharacterConfigurationRevision;
        if (fromRevision != currentRevision)
        {
            return new CharacterSheetWriteResult
            {
                Status = CharacterSheetWriteStatus.Conflict,
                Revision = currentRevision,
                Message = $"Stale fromRevision. Current revision is {currentRevision}.",
            };
        }

        if (!ConfigDocumentPatcher.TryApply(updated.RpgCharacterConfiguration, patchJson, out var resultJson, out var error))
        {
            return new CharacterSheetWriteResult
            {
                Status = CharacterSheetWriteStatus.InvalidPatch,
                Revision = currentRevision,
                Message = $"Could not apply patch: {error}",
            };
        }

        if (validate)
        {
            var problems = CharacterSheetValidator.FindNewProblems(
                updated.RpgCharacterConfiguration,
                resultJson,
                await LoadCampagneConfigAsync(updated.CampagneId, cancellationToken).ConfigureAwait(false)
            );
            if (problems.Count > 0)
            {
                return new CharacterSheetWriteResult
                {
                    Status = CharacterSheetWriteStatus.InvalidSheet,
                    Revision = currentRevision,
                    Message = "The patched sheet would not be valid any more; nothing was saved.",
                    Problems = problems,
                };
            }
        }

        var newRevision = currentRevision + 1;
        updated.RpgCharacterConfiguration = resultJson;
        updated.RpgCharacterConfigurationRevision = newRevision;

        var updateResult = await new PlayerCharacterUpdateQuery { UpdatedModel = updated }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return new CharacterSheetWriteResult
            {
                Status = CharacterSheetWriteStatus.Failed,
                Revision = currentRevision,
                Message = "Could not update player character configuration",
            };
        }

        await _configRevisionHistoryStore
            .RecordPlayerCharacterSnapshotAsync(playerCharacterId, newRevision, resultJson, cancellationToken)
            .ConfigureAwait(false);

        var timestamp = DateTime.Now.ToString("yyyyMMdd-HHmm");
        await ConfigFileBackupWriter
            .WriteBackupAsync(
                _hostEnvironment,
                _logger,
                $"{updated.CharacterName}-{playerCharacterId}-{timestamp}-rpgbackup.json",
                resultJson,
                cancellationToken
            )
            .ConfigureAwait(false);

        if (source != null)
        {
            _logger.LogInformation(
                "Character {PlayerCharacterId} sheet changed to revision {Revision} by {Source}",
                playerCharacterId,
                newRevision,
                source
            );
        }

        // A write from another app (source set) must also reach the player's own Questkeeper app.
        await NotifyCharacterConfigChangedAsync(
                playerCharacterId,
                updated.CampagneId,
                newRevision,
                excludedUserId: source == null ? actorUserId : null,
                cancellationToken
            )
            .ConfigureAwait(false);

        return new CharacterSheetWriteResult { Status = CharacterSheetWriteStatus.Saved, Revision = newRevision };
    }

    private async Task<string?> LoadCampagneConfigAsync(
        Campagne.CampagneIdentifier? campagneId,
        CancellationToken cancellationToken
    )
    {
        if (campagneId == null)
        {
            return null;
        }

        var campagne = await new CampagneQuery { ModelId = campagneId }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);
        return campagne.IsSome ? campagne.Get().RpgConfiguration : null;
    }

    /// <summary>
    /// Emits a session-scoped <c>characterConfigChanged</c> SSE notify (<c>{ id, revision }</c> only, no body)
    /// to the users currently in the owning campagne's table session, except <paramref name="excludedUserId"/>.
    /// No-op if the character is not assigned to a campagne, or nobody else is online.
    /// </summary>
    private Task NotifyCharacterConfigChangedAsync(
        Guid playerCharacterId,
        Campagne.CampagneIdentifier? campagneId,
        int revision,
        Guid? excludedUserId,
        CancellationToken cancellationToken
    )
    {
        if (campagneId == null)
        {
            return Task.CompletedTask;
        }

        var recipients = _sessionPresenceService
            .GetOnlineParticipants(campagneId.Value)
            .Where(id => id != excludedUserId)
            .ToList();

        if (recipients.Count == 0)
        {
            return Task.CompletedTask;
        }

        var payload = JsonSerializer.Serialize(new { id = playerCharacterId.ToString(), revision });
        return _sseEventHub.SendToUsersAsync(recipients, "characterConfigChanged", payload, cancellationToken);
    }
}
