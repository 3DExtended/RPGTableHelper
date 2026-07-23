using Microsoft.EntityFrameworkCore;

using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.WebApi.Services.ConfigRevisions;

public class ConfigRevisionHistoryStore : IConfigRevisionHistoryStore
{
    /// <summary>Number of full-document snapshots retained per campagne/character.</summary>
    public const int HistoryWindowSize = 10;

    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public ConfigRevisionHistoryStore(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task RecordCampagneSnapshotAsync(
        Guid campagneId,
        int revision,
        string configJson,
        CancellationToken cancellationToken
    )
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        await context.CampagneRpgConfigHistories
            .AddAsync(
                new CampagneRpgConfigHistoryEntity { CampagneId = campagneId, Revision = revision, ConfigJson = configJson },
                cancellationToken
            )
            .ConfigureAwait(false);
        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var idsBeyondWindow = await context.CampagneRpgConfigHistories
            .Where(h => h.CampagneId == campagneId)
            .OrderByDescending(h => h.Revision)
            .Skip(HistoryWindowSize)
            .Select(h => h.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (idsBeyondWindow.Count > 0)
        {
            context.CampagneRpgConfigHistories.RemoveRange(
                context.CampagneRpgConfigHistories.Where(h => idsBeyondWindow.Contains(h.Id))
            );
            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }

    public async Task<string?> GetCampagneSnapshotAsync(Guid campagneId, int revision, CancellationToken cancellationToken)
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        return await context.CampagneRpgConfigHistories
            .Where(h => h.CampagneId == campagneId && h.Revision == revision)
            .Select(h => h.ConfigJson)
            .SingleOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task RecordPlayerCharacterSnapshotAsync(
        Guid playerCharacterId,
        int revision,
        string configJson,
        CancellationToken cancellationToken
    )
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        await context.PlayerCharacterRpgConfigHistories
            .AddAsync(
                new PlayerCharacterRpgConfigHistoryEntity
                {
                    PlayerCharacterId = playerCharacterId,
                    Revision = revision,
                    ConfigJson = configJson,
                },
                cancellationToken
            )
            .ConfigureAwait(false);
        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var idsBeyondWindow = await context.PlayerCharacterRpgConfigHistories
            .Where(h => h.PlayerCharacterId == playerCharacterId)
            .OrderByDescending(h => h.Revision)
            .Skip(HistoryWindowSize)
            .Select(h => h.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (idsBeyondWindow.Count > 0)
        {
            context.PlayerCharacterRpgConfigHistories.RemoveRange(
                context.PlayerCharacterRpgConfigHistories.Where(h => idsBeyondWindow.Contains(h.Id))
            );
            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }

    public async Task<string?> GetPlayerCharacterSnapshotAsync(
        Guid playerCharacterId,
        int revision,
        CancellationToken cancellationToken
    )
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        return await context.PlayerCharacterRpgConfigHistories
            .Where(h => h.PlayerCharacterId == playerCharacterId && h.Revision == revision)
            .Select(h => h.ConfigJson)
            .SingleOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
    }
}
