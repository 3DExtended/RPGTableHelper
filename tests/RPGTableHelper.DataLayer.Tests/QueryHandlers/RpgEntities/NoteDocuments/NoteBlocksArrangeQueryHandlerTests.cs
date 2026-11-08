using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using NSubstitute;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlocksArrangeQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_OrdersAndMovesBlocks_KeepingWhoMayReadThem()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var reader = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "Reader");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var source = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var target = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var inTarget = AddTextBlock(target.Id.Value, owner.Id.Value, "in target");
        var shared = AddTextBlock(source.Id.Value, owner.Id.Value, "shared");
        Context.PermittedUsersToNotesBlocks.Add(
            new PermittedUsersToNotesBlockEntity { NotesBlockId = shared.Id, PermittedUserId = reader.Id.Value }
        );
        Context.SaveChanges();

        var later = new DateTimeOffset(2024, 02, 02, 12, 0, 0, TimeSpan.Zero);
        SystemClock.Now.Returns(later);
        var subjectUnderTest = new NoteBlocksArrangeQueryHandler(ContextFactory);

        // act
        var result = await subjectUnderTest.RunQueryAsync(
            new NoteBlocksArrangeQuery
            {
                DocumentId = target.Id,
                OrderedBlockIds = new[]
                {
                    NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(shared.Id),
                    NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(inTarget.Id),
                },
            },
            default
        );

        // assert
        result.IsSome.Should().BeTrue();
        var blocks = Context
            .NoteBlocks.Include(b => b.PermittedUsers)
            .AsNoTracking()
            .Where(b => b.NoteDocumentId == target.Id.Value)
            .OrderBy(b => b.SortIndex)
            .ToList();
        blocks.Select(b => b.Id).Should().Equal(shared.Id, inTarget.Id);
        blocks.Select(b => b.SortIndex).Should().Equal(0, 1);
        blocks[0].PermittedUsers.Select(p => p.PermittedUserId).Should().Equal(reader.Id.Value);
        blocks[0].As<TextBlockEntity>().MarkdownText.Should().Be("shared");

        var documents = Context.CampagneDocuments.AsNoTracking().Where(d => d.Id == source.Id.Value || d.Id == target.Id.Value);
        documents.Select(d => d.LastModifiedAt).Should().AllBeEquivalentTo(later, "both documents changed");
    }

    [Fact]
    public async Task RunQueryAsync_WithAnUnknownBlock_ChangesNothing()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var source = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var target = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var block = AddTextBlock(source.Id.Value, owner.Id.Value, "stays");
        Context.SaveChanges();
        var subjectUnderTest = new NoteBlocksArrangeQueryHandler(ContextFactory);

        // act
        var result = await subjectUnderTest.RunQueryAsync(
            new NoteBlocksArrangeQuery
            {
                DocumentId = target.Id,
                OrderedBlockIds = new[]
                {
                    NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(block.Id),
                    NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
                },
            },
            default
        );

        // assert
        result.IsNone.Should().BeTrue();
        var reloaded = Context.NoteBlocks.AsNoTracking().Single(b => b.Id == block.Id);
        reloaded.NoteDocumentId.Should().Be(source.Id.Value);
        reloaded.SortIndex.Should().BeNull();
    }

    private TextBlockEntity AddTextBlock(Guid documentId, Guid userId, string text)
    {
        var block = new TextBlockEntity
        {
            Id = Guid.NewGuid(),
            MarkdownText = text,
            CreatingUserId = userId,
            NoteDocumentId = documentId,
        };
        Context.NoteBlocks.Add(block);
        Context.SaveChanges();
        return block;
    }
}
