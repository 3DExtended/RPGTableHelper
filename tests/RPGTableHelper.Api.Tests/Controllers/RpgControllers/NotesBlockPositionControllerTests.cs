using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using Xunit;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

/// <summary>Inserting blocks at a position, moving them, and adding or removing a block's image.</summary>
public class NotesBlockPositionControllerTests : ControllerTestBase
{
    public NotesBlockPositionControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateTextBlock_WithInsertBeforeBlockId_PutsTheNewBlockBeforeIt()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var first = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "first", sortIndex: 0);
        var second = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "second", sortIndex: 1);

        // act
        var response = await Client.PostAsJsonAsync(
            $"/notes/createtextblock/{document.Id.Value}?insertBeforeBlockId={second}",
            NewTextBlock(owner, document, "between")
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var created = await response.Content.ReadFromJsonAsync<TextBlock>();
        created!.SortIndex.Should().Be(1);
        OrderOf(document.Id.Value).Should().Equal(first, created.Id.Value, second);
    }

    [Fact]
    public async Task CreateTextBlock_WithoutInsertBeforeBlockId_StillGoesLast()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var first = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "first", sortIndex: 0);

        // act
        var response = await Client.PostAsJsonAsync(
            $"/notes/createtextblock/{document.Id.Value}",
            NewTextBlock(owner, document, "last")
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var created = await response.Content.ReadFromJsonAsync<TextBlock>();
        OrderOf(document.Id.Value).Should().Equal(first, created!.Id.Value);
    }

    [Fact]
    public async Task CreateTextBlock_WithABlockOfAnotherDocument_IsRejected_AndCreatesNothing()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var other = await RpgDbContextHelpers.CreateNoteDocumentInDb(
            ContextFactory!,
            Mapper!,
            owner,
            new DataLayer.Contracts.Models.RpgEntities.Campagne { Id = document.CreatedForCampagneId }
        );
        var elsewhere = await AddTextBlockAsync(other.Id.Value, owner.Id.Value, "elsewhere", sortIndex: null);

        // act
        var response = await Client.PostAsJsonAsync(
            $"/notes/createtextblock/{document.Id.Value}?insertBeforeBlockId={elsewhere}",
            NewTextBlock(owner, document, "new")
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        Context.NoteBlocks.AsNoTracking().Count(b => b.NoteDocumentId == document.Id.Value).Should().Be(0);
    }

    [Fact]
    public async Task MoveBlock_PutsTheBlockBeforeTheAnchor_AndReturnsTheDocumentInItsNewOrder()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var first = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "first", sortIndex: 0);
        var second = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "second", sortIndex: 1);
        var third = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "third", sortIndex: 2);

        // act
        var response = await Client.PutAsync($"/notes/moveblock/{third}?beforeblockid={first}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var returned = await response.Content.ReadFromJsonAsync<NoteDocumentDto>();
        returned!
            .TextBlocks.OrderBy(b => b.SortIndex)
            .Select(b => b.Id.Value)
            .Should()
            .Equal(third, first, second);
        OrderOf(document.Id.Value).Should().Equal(third, first, second);
    }

    [Fact]
    public async Task MoveBlock_WithoutAnchor_MovesTheBlockToTheEnd()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var first = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "first", sortIndex: 0);
        var second = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "second", sortIndex: 1);

        // act
        var response = await Client.PutAsync($"/notes/moveblock/{first}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        OrderOf(document.Id.Value).Should().Equal(second, first);
    }

    [Fact]
    public async Task MoveBlock_OfSomeoneElse_IsUnauthorized()
    {
        // arrange
        await ConfigureLoggedInUser();
        var stranger = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Stranger");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, stranger);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, stranger, campagne);
        var block = await AddTextBlockAsync(document.Id.Value, stranger.Id.Value, "theirs", sortIndex: null);

        // act
        var response = await Client.PutAsync($"/notes/moveblock/{block}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        Context.NoteBlocks.AsNoTracking().Single(b => b.Id == block).SortIndex.Should().BeNull();
    }

    [Fact]
    public async Task AttachImage_TurnsTheTextBlockIntoAnImageBlock_AtTheSamePosition()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var campagne = new DataLayer.Contracts.Models.RpgEntities.Campagne { Id = document.CreatedForCampagneId };
        var image = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory!, Mapper!, owner, campagne);
        var first = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "first", sortIndex: null);
        var text = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "the text", sortIndex: null);
        var last = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "last", sortIndex: null);

        // act
        var response = await Client.PostAsJsonAsync(
            $"/notes/attachimage/{text}",
            new NoteBlockImageDto { ImageMetaDataId = image.Id, PublicImageUrl = "/public/getimage/abc" }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var imageBlock = await response.Content.ReadFromJsonAsync<ImageBlock>();
        imageBlock!.MarkdownText.Should().Be("the text");
        imageBlock.PublicImageUrl.Should().Be("/public/getimage/abc");
        imageBlock.Id.Value.Should().NotBe(text);
        OrderOf(document.Id.Value).Should().Equal(first, imageBlock.Id.Value, last);
    }

    [Fact]
    public async Task AttachImage_ToAnImageBlock_IsRejected()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var text = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "text", sortIndex: null);
        var imageBlockId = await AttachImageAsync(owner, document, text);

        // act
        var response = await Client.PostAsJsonAsync(
            $"/notes/attachimage/{imageBlockId}",
            new NoteBlockImageDto
            {
                ImageMetaDataId = DataLayer.Contracts.Models.Images.ImageMetaData.ImageMetaDataIdentifier.From(
                    Guid.NewGuid()
                ),
                PublicImageUrl = "/public/getimage/other",
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task RemoveImage_TurnsTheImageBlockBackIntoATextBlock_KeepingTheText()
    {
        // arrange
        var (owner, document) = await CreateOwnDocumentAsync();
        var text = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "caption", sortIndex: null);
        var after = await AddTextBlockAsync(document.Id.Value, owner.Id.Value, "after", sortIndex: null);
        var imageBlockId = await AttachImageAsync(owner, document, text);

        // act
        var response = await Client.PostAsync($"/notes/removeimage/{imageBlockId}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var textBlock = await response.Content.ReadFromJsonAsync<TextBlock>();
        textBlock!.MarkdownText.Should().Be("caption");
        OrderOf(document.Id.Value).Should().Equal(textBlock.Id.Value, after);
        Context.NoteBlocks.AsNoTracking().OfType<ImageBlockEntity>().Should().BeEmpty();
    }

    private static TextBlock NewTextBlock(User owner, NoteDocument document, string text) =>
        new()
        {
            MarkdownText = text,
            NoteDocumentId = document.Id,
            CreatingUserId = owner.Id,
            PermittedUsers = new List<User.UserIdentifier>(),
        };

    private async Task<Guid> AttachImageAsync(User owner, NoteDocument document, Guid textBlockId)
    {
        var campagne = new DataLayer.Contracts.Models.RpgEntities.Campagne
        {
            Id = document.CreatedForCampagneId,
        };
        var image = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory!, Mapper!, owner, campagne);
        var response = await Client.PostAsJsonAsync(
            $"/notes/attachimage/{textBlockId}",
            new NoteBlockImageDto { ImageMetaDataId = image.Id, PublicImageUrl = "/public/getimage/abc" }
        );
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<ImageBlock>())!.Id.Value;
    }

    private async Task<(User Owner, NoteDocument Document)> CreateOwnDocumentAsync()
    {
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);
        return (owner, document);
    }

    private async Task<Guid> AddTextBlockAsync(Guid documentId, Guid userId, string text, int? sortIndex)
    {
        var block = new TextBlockEntity
        {
            Id = Guid.NewGuid(),
            MarkdownText = text,
            CreatingUserId = userId,
            NoteDocumentId = documentId,
            SortIndex = sortIndex,
        };
        using var context = ContextFactory!.CreateDbContext();
        await context.NoteBlocks.AddAsync(block);
        await context.SaveChangesAsync();

        // distinct creation dates, so blocks without a position keep the order they were added in
        await Task.Delay(5);
        return block.Id;
    }

    private List<Guid> OrderOf(Guid documentId)
    {
        using var context = ContextFactory!.CreateDbContext();
        return context
            .NoteBlocks.AsNoTracking()
            .Where(b => b.NoteDocumentId == documentId)
            .OrderBy(b => b.SortIndex)
            .Select(b => b.Id)
            .ToList();
    }
}
