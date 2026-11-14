using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteBlockReplaceQueryHandler
    : IQueryHandler<NoteBlockReplaceQuery, NoteBlockModelBase.NoteBlockModelBaseIdentifier>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;
    private readonly IMapper _mapper;

    public NoteBlockReplaceQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
    {
        _mapper = mapper;
        _contextFactory = contextFactory;
    }

    public IQueryHandler<NoteBlockReplaceQuery, NoteBlockModelBase.NoteBlockModelBaseIdentifier> Successor { get; set; } =
        default!;

    public async Task<Option<NoteBlockModelBase.NoteBlockModelBaseIdentifier>> RunQueryAsync(
        NoteBlockReplaceQuery query,
        CancellationToken cancellationToken
    )
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        var old = await context
            .NoteBlocks.Include(b => b.PermittedUsers)
            .FirstOrDefaultAsync(b => b.Id == query.BlockId.Value, cancellationToken)
            .ConfigureAwait(false);
        if (old == null)
        {
            return Option.None;
        }

        // Number the document first: the new block is created now, so without a position of its own it would
        // sort by its creation date, i.e. last.
        var blocks = await NoteBlockOrder
            .LoadInDocumentOrderAsync(context, old.NoteDocumentId, cancellationToken)
            .ConfigureAwait(false);
        NoteBlockOrder.Number(blocks);

        var newId = Guid.NewGuid();
        var model = query.Replacement;
        model.Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(newId);
        model.NoteDocumentId = NoteDocument.NoteDocumentIdentifier.From(old.NoteDocumentId);
        model.CreatingUserId = User.UserIdentifier.From(old.CreatingUserId);
        model.SortIndex = old.SortIndex;
        model.IsDeleted = false;

        var replacement = _mapper.Map<NoteBlockEntityBase>(model);
        replacement.PermittedUsers = old
            .PermittedUsers.Where(p => !p.IsDeleted)
            .Select(p => new PermittedUsersToNotesBlockEntity
            {
                NotesBlockId = newId,
                PermittedUserId = p.PermittedUserId,
            })
            .ToList();
        await context.NoteBlocks.AddAsync(replacement, cancellationToken).ConfigureAwait(false);

        old.IsDeleted = true;
        await NoteDocumentTouch
            .MarkModifiedAsync(context, new[] { old.NoteDocumentId }, cancellationToken)
            .ConfigureAwait(false);
        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(newId);
    }
}
