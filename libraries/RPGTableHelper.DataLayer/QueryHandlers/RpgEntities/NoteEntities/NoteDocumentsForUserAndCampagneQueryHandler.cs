using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteDocumentsForUserAndCampagneQueryHandler
    : IQueryHandler<NoteDocumentsForUserAndCampagneQuery, IReadOnlyList<NoteDocument>>
{
    public IQueryHandler<NoteDocumentsForUserAndCampagneQuery, IReadOnlyList<NoteDocument>> Successor { get; set; } =
        default!;

    private readonly IDbContextFactory<RpgDbContext> _contextFactory;
    private readonly IMapper _mapper;

    public NoteDocumentsForUserAndCampagneQueryHandler(IDbContextFactory<RpgDbContext> contextFactory, IMapper mapper)
    {
        _contextFactory = contextFactory;
        _mapper = mapper;
    }

    public async Task<Option<IReadOnlyList<NoteDocument>>> RunQueryAsync(
        NoteDocumentsForUserAndCampagneQuery query,
        CancellationToken cancellationToken
    )
    {
        using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
        {
            var entities = await context
                .CampagneDocuments.Where(cp =>
                    cp.CreatedForCampagneId == query.CampagneId.Value
                    && (
                        cp.CreatingUserId == query.UserId.Value
                        || cp.NoteBlocks.Any(nb =>
                            nb.PermittedUsers.Any(pu => pu.PermittedUserId == query.UserId.Value)
                        )
                    )
                )
                .Include(d => d.NoteBlocks)
                .ThenInclude(nb => nb.PermittedUsers)
                .AsNoTracking()
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

            if (entities == null)
            {
                return Option.None;
            }

            if (entities.Count == 0)
            {
                return new List<NoteDocument>();
            }

            var result = new List<NoteDocument>();
            foreach (var entity in entities)
            {
                var mappedEntity = _mapper.Map<NoteDocument>(entity);

                if (mappedEntity.CreatingUserId != query.UserId)
                {
                    mappedEntity.NoteBlocks = mappedEntity
                        .NoteBlocks.Where(nb => nb.PermittedUsers.Any(pu => pu == query.UserId))
                        .ToList();
                }

                result.Add(mappedEntity);
            }

            return result;
        }
    }
}
