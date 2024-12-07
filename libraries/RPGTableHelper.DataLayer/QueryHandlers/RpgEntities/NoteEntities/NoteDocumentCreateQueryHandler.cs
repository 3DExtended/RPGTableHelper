using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteDocumentCreateQueryHandler
    : IQueryHandler<NoteDocumentCreateQuery, NoteDocument.NoteDocumentIdentifier>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;
    private readonly IMapper _mapper;
    private readonly IQueryProcessor _queryProcessor;

    public NoteDocumentCreateQueryHandler(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        IQueryProcessor queryProcessor
    )
    {
        _contextFactory = contextFactory;
        _mapper = mapper;
        _queryProcessor = queryProcessor;
    }

    public IQueryHandler<NoteDocumentCreateQuery, NoteDocument.NoteDocumentIdentifier> Successor { get; set; } =
        default!;

    public async Task<Option<NoteDocument.NoteDocumentIdentifier>> RunQueryAsync(
        NoteDocumentCreateQuery query,
        CancellationToken cancellationToken
    )
    {
        using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
        {
            var preparedModel = query.ModelToCreate;

            var blocksToCreateWith = preparedModel.NoteBlocks;
            preparedModel.NoteBlocks = new List<NoteBlockModelBase>();

            var entity = _mapper.Map<NoteDocumentEntity>(preparedModel);
            await context.CampagneDocuments.AddAsync(entity, cancellationToken).ConfigureAwait(false);
            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            var documentId = NoteDocument.NoteDocumentIdentifier.From(entity.Id);

            foreach (var block in blocksToCreateWith)
            {
                block.NoteDocumentId = documentId;
                block.CreatingUserId = query.ModelToCreate.CreatingUserId;

                var blockCreationResult = await new NoteBlockCreateQuery { ModelToCreate = block }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (blockCreationResult.IsNone)
                {
                    return Option.None;
                }
            }

            return documentId;
        }
    }
}
