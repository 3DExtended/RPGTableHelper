using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using NSubstitute;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlockMoveQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_InADocumentThatWasNeverArranged_MovesTheBlockBeforeTheAnchor_AndNumbersAllBlocks()
    {
        // arrange: no SortIndex yet, so the order is the creation order
        var (owner, document) = await CreateDocumentAsync();
        var first = AddTextBlock(document.Id.Value, owner.Id.Value, "first", at: 1);
        var second = AddTextBlock(document.Id.Value, owner.Id.Value, "second", at: 2);
        var third = AddTextBlock(document.Id.Value, owner.Id.Value, "third", at: 3);
        var later = new DateTimeOffset(2024, 05, 05, 12, 0, 0, TimeSpan.Zero);
        SystemClock.Now.Returns(later);

        // act
        var result = await Move(third.Id, beforeBlockId: second.Id);

        // assert
        result.IsSome.Should().BeTrue();
        OrderOf(document.Id.Value).Should().Equal(first.Id, third.Id, second.Id);
        Context.NoteBlocks.AsNoTracking().Select(b => b.SortIndex).Should().BeEquivalentTo(new int?[] { 0, 1, 2 });
        Context.CampagneDocuments.AsNoTracking().Single(d => d.Id == document.Id.Value).LastModifiedAt.Should().Be(later);
    }

    [Fact]
    public async Task RunQueryAsync_WithoutAnAnchor_MovesTheBlockToTheEnd()
    {
        // arrange
        var (owner, document) = await CreateDocumentAsync();
        var first = AddTextBlock(document.Id.Value, owner.Id.Value, "first", at: 1, sortIndex: 0);
        var second = AddTextBlock(document.Id.Value, owner.Id.Value, "second", at: 2, sortIndex: 1);
        var third = AddTextBlock(document.Id.Value, owner.Id.Value, "third", at: 3, sortIndex: 2);

        // act
        var result = await Move(first.Id, beforeBlockId: null);

        // assert
        result.IsSome.Should().BeTrue();
        OrderOf(document.Id.Value).Should().Equal(second.Id, third.Id, first.Id);
    }

    [Fact]
    public async Task RunQueryAsync_MovingDown_PutsTheBlockAfterItsNextNeighbour()
    {
        // arrange
        var (owner, document) = await CreateDocumentAsync();
        var first = AddTextBlock(document.Id.Value, owner.Id.Value, "first", at: 1, sortIndex: 0);
        var second = AddTextBlock(document.Id.Value, owner.Id.Value, "second", at: 2, sortIndex: 1);
        var third = AddTextBlock(document.Id.Value, owner.Id.Value, "third", at: 3, sortIndex: 2);

        // act: "down" for the first block is "before the block after the next one"
        var result = await Move(first.Id, beforeBlockId: third.Id);

        // assert
        result.IsSome.Should().BeTrue();
        OrderOf(document.Id.Value).Should().Equal(second.Id, first.Id, third.Id);
    }

    [Fact]
    public async Task RunQueryAsync_WithAnAnchorInAnotherDocument_ChangesNothing()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var other = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var block = AddTextBlock(document.Id.Value, owner.Id.Value, "block", at: 1);
        var elsewhere = AddTextBlock(other.Id.Value, owner.Id.Value, "elsewhere", at: 2);

        // act
        var result = await Move(block.Id, beforeBlockId: elsewhere.Id);

        // assert
        result.IsNone.Should().BeTrue();
        Context.NoteBlocks.AsNoTracking().Select(b => b.SortIndex).Should().AllBeEquivalentTo((int?)null);
    }

    [Fact]
    public async Task RunQueryAsync_WithTheBlockItselfAsAnchor_ChangesNothing()
    {
        // arrange
        var (owner, document) = await CreateDocumentAsync();
        var block = AddTextBlock(document.Id.Value, owner.Id.Value, "block", at: 1);

        // act
        var result = await Move(block.Id, beforeBlockId: block.Id);

        // assert
        result.IsNone.Should().BeTrue();
        Context.NoteBlocks.AsNoTracking().Single().SortIndex.Should().BeNull();
    }

    private async Task<(Contracts.Models.Auth.User Owner, NoteDocument Document)> CreateDocumentAsync()
    {
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        return (owner, document);
    }

    private Task<Prodot.Patterns.Cqrs.Option<Prodot.Patterns.Cqrs.Unit>> Move(Guid blockId, Guid? beforeBlockId) =>
        new NoteBlockMoveQueryHandler(ContextFactory).RunQueryAsync(
            new NoteBlockMoveQuery
            {
                BlockId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockId),
                BeforeBlockId = beforeBlockId == null
                    ? Prodot.Patterns.Cqrs.Option.None
                    : Prodot.Patterns.Cqrs.Option.From(
                        NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(beforeBlockId.Value)
                    ),
            },
            default
        );

    private List<Guid> OrderOf(Guid documentId) =>
        Context
            .NoteBlocks.AsNoTracking()
            .Where(b => b.NoteDocumentId == documentId)
            .OrderBy(b => b.SortIndex)
            .Select(b => b.Id)
            .ToList();

    private TextBlockEntity AddTextBlock(Guid documentId, Guid userId, string text, int at, int? sortIndex = null)
    {
        SystemClock.Now.Returns(new DateTimeOffset(2024, 01, 01, at, 0, 0, TimeSpan.Zero));
        var block = new TextBlockEntity
        {
            Id = Guid.NewGuid(),
            MarkdownText = text,
            CreatingUserId = userId,
            NoteDocumentId = documentId,
            SortIndex = sortIndex,
        };
        Context.NoteBlocks.Add(block);
        Context.SaveChanges();
        return block;
    }
}
