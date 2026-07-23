namespace RPGTableHelper.WebApi.Services.ConfigRevisions;

/// <summary>
/// Stores and retrieves the last ~10 full-document snapshots per campagne/character config, so clients that
/// missed some revisions can catch up via a computed JSON Patch instead of always re-downloading the full document.
/// </summary>
public interface IConfigRevisionHistoryStore
{
    Task RecordCampagneSnapshotAsync(Guid campagneId, int revision, string configJson, CancellationToken cancellationToken);

    Task<string?> GetCampagneSnapshotAsync(Guid campagneId, int revision, CancellationToken cancellationToken);

    Task RecordPlayerCharacterSnapshotAsync(
        Guid playerCharacterId,
        int revision,
        string configJson,
        CancellationToken cancellationToken
    );

    Task<string?> GetPlayerCharacterSnapshotAsync(Guid playerCharacterId, int revision, CancellationToken cancellationToken);
}
