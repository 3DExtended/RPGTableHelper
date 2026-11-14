using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using NSubstitute;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlockReplaceQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_TextBlockByImageBlock_KeepsPositionTextAndReaders_AndDeletesTheTextBlock()
    {
        // arrange: a document that was never arranged; the middle block gets the image
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var reader = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "Reader");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var image = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory, Mapper, owner, campagne);
        var first = AddTextBlock(document.Id.Value, owner.Id.Value, "first", at: 1);
        var middle = AddTextBlock(document.Id.Value, owner.Id.Value, "middle", at: 2);
        var last = AddTextBlock(document.Id.Value, owner.Id.Value, "last", at: 3);
        Context.PermittedUsersToNotesBlocks.Add(
            new PermittedUsersToNotesBlockEntity { NotesBlockId = middle.Id, PermittedUserId = reader.Id.Value }
        );
        Context.SaveChanges();
        SystemClock.Now.Returns(new DateTimeOffset(2024, 06, 06, 12, 0, 0, TimeSpan.Zero));

        // act
        var result = await new NoteBlockReplaceQueryHandler(Mapper, ContextFactory).RunQueryAsync(
            new NoteBlockReplaceQuery
            {
                BlockId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(middle.Id),
                Replacement = new ImageBlock
                {
                    MarkdownText = "middle",
                    ImageMetaDataId = image.Id,
                    PublicImageUrl = "/public/getimage/x",
                },
            },
            default
        );

        // assert
        result.IsSome.Should().BeTrue();
        var newId = result.Get().Value;
        newId.Should().NotBe(middle.Id);

        var blocks = Context
            .NoteBlocks.Include(b => b.PermittedUsers)
            .AsNoTracking()
            .Where(b => b.NoteDocumentId == document.Id.Value)
            .OrderBy(b => b.SortIndex)
            .ToList();
        blocks.Select(b => b.Id).Should().Equal(first.Id, newId, last.Id);
        blocks.Select(b => b.SortIndex).Should().Equal(0, 1, 2);

        var replacement = blocks[1].Should().BeOfType<ImageBlockEntity>().Subject;
        replacement.MarkdownText.Should().Be("middle");
        replacement.ImageMetaDataId.Should().Be(image.Id.Value);
        replacement.PublicImageUrl.Should().Be("/public/getimage/x");
        replacement.CreatingUserId.Should().Be(owner.Id.Value);
        replacement.PermittedUsers.Select(p => p.PermittedUserId).Should().Equal(reader.Id.Value);

        Context.NoteBlocks.IgnoreQueryFilters().AsNoTracking().Single(b => b.Id == middle.Id).IsDeleted.Should().BeTrue();
    }

    [Fact]
    public async Task RunQueryAsync_WithAnUnknownBlock_ChangesNothing()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        AddTextBlock(document.Id.Value, owner.Id.Value, "stays", at: 1);

        // act
        var result = await new NoteBlockReplaceQueryHandler(Mapper, ContextFactory).RunQueryAsync(
            new NoteBlockReplaceQuery
            {
                BlockId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
                Replacement = new TextBlock { MarkdownText = "new" },
            },
            default
        );

        // assert
        result.IsNone.Should().BeTrue();
        Context.NoteBlocks.AsNoTracking().Should().ContainSingle().Which.SortIndex.Should().BeNull();
    }

    private TextBlockEntity AddTextBlock(Guid documentId, Guid userId, string text, int at)
    {
        SystemClock.Now.Returns(new DateTimeOffset(2024, 01, 01, at, 0, 0, TimeSpan.Zero));
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
