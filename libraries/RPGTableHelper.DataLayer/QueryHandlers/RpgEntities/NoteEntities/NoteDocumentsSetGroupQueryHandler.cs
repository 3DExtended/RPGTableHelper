using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteDocumentsSetGroupQueryHandler : IQueryHandler<NoteDocumentsSetGroupQuery, Unit>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public NoteDocumentsSetGroupQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public IQueryHandler<NoteDocumentsSetGroupQuery, Unit> Successor { get; set; } = default!;

    public async Task<Option<Unit>> RunQueryAsync(NoteDocumentsSetGroupQuery query, CancellationToken cancellationToken)
    {
        var ids = query.DocumentIds.Select(id => id.Value).Distinct().ToList();

        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
        var documents = await context
            .CampagneDocuments.Where(d => ids.Contains(d.Id))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (documents.Count != ids.Count)
        {
            return Option.None;
        }

        foreach (var document in documents)
        {
            document.GroupName = query.GroupName;
        }

        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return Unit.Value;
    }
}
