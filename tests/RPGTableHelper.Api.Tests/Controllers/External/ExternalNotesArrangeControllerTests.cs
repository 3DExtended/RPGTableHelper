using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.External;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// Restructuring notes through the player API: ordering blocks, moving them between documents, adding several at
/// once and moving documents between folders. Whatever moves keeps exactly who may read it, and a write that names
/// an older document version changes nothing.
/// </summary>
public class ExternalNotesArrangeControllerTests : ExternalApiTestBase
{
    private static readonly byte[] PngBytes = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x01 };

    public ExternalNotesArrangeControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task BlockOrder_PutsTheBlocksInTheNewOrder()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var first = await CreateBlockAsync(key, document.Id, "first");
        var second = await CreateBlockAsync(key, document.Id, "second");
        var third = await CreateBlockAsync(key, document.Id, "third");

        // act
        var response = await key.PutAsync(
            $"{V1}/documents/{document.Id}/block-order",
            Json(new { blockIds = new[] { third.Id, first.Id, second.Id } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var arranged = await response.Content.ReadFromJsonAsync<ExternalNoteDocumentDto>(JsonOptions);
        arranged!.Blocks.Select(b => b.MarkdownText).Should().Equal("third", "first", "second");
        var reloaded = await GetDocumentAsync(key, document.Id);
        reloaded.Blocks.Select(b => b.Id).Should().Equal(third.Id, first.Id, second.Id);
    }

    [Fact]
    public async Task BlockOrder_MovingBlocksFromAnotherDocument_KeepsTheirIdContentImageAndReaders()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateKeyAsync(hero);
        var source = await CreateDocumentAsync(key, campagne.Id.Value, "Old notes", "Archive");
        var shared = await CreateBlockAsync(key, source.Id, "For the DM", dm.Id.Value);
        var image = await CreateImageBlockAsync(key, source.Id, "Map", rogue.User.Id.Value);
        var target = await CreateDocumentAsync(key, campagne.Id.Value, "All notes", "Heist");
        var private1 = await CreateBlockAsync(key, target.Id, "Only mine");

        // act
        var response = await key.PutAsync(
            $"{V1}/documents/{target.Id}/block-order",
            Json(new { blockIds = new[] { private1.Id, shared.Id, image.Id } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var merged = await GetDocumentAsync(key, target.Id);
        merged.Blocks.Select(b => b.Id).Should().Equal(private1.Id, shared.Id, image.Id);
        merged.Blocks[0].VisibleTo.Should().BeEmpty();
        merged.Blocks[1].VisibleTo.Should().Equal(dm.Id.Value);
        merged.Blocks[1].MarkdownText.Should().Be("For the DM");
        merged.Blocks[2].VisibleTo.Should().Equal(rogue.User.Id.Value);
        merged.Blocks[2].ImageUrl.Should().Be(image.ImageUrl);
        merged.Blocks[2].MarkdownText.Should().Be("Map");
        (await GetDocumentAsync(key, source.Id)).Blocks.Should().BeEmpty();

        var dmView = await GetDocumentAsync(await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead), target.Id);
        dmView.Blocks.Select(b => b.Id).Should().Equal(shared.Id);
        var rogueView = await GetDocumentAsync(await CreateApiKeyClientAsync(rogue.User, ApiKeyScopes.NotesRead), target.Id);
        rogueView.Blocks.Select(b => b.Id).Should().Equal(image.Id);
    }

    [Fact]
    public async Task BlockOrder_ThatLeavesABlockOut_ChangesNothing()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var first = await CreateBlockAsync(key, document.Id, "first");
        var second = await CreateBlockAsync(key, document.Id, "second");

        // act
        var missing = await key.PutAsync($"{V1}/documents/{document.Id}/block-order", Json(new { blockIds = new[] { second.Id } }));
        var twice = await key.PutAsync(
            $"{V1}/documents/{document.Id}/block-order",
            Json(new { blockIds = new[] { second.Id, first.Id, second.Id } })
        );

        // assert
        missing.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await missing.Content.ReadAsStringAsync()).Should().Contain(first.Id.ToString());
        twice.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await GetDocumentAsync(key, document.Id)).Blocks.Select(b => b.Id).Should().Equal(first.Id, second.Id);
    }

    [Fact]
    public async Task BlockOrder_WithABlockThatIsNotYours_ChangesNothing()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead, ApiKeyScopes.NotesWrite);
        var dmDocument = await CreateDocumentAsync(dmKey, campagne.Id.Value, "Lore", "World");
        var dmBlock = await CreateBlockAsync(dmKey, dmDocument.Id, "Shared lore", hero.User.Id.Value);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var own = await CreateBlockAsync(key, document.Id, "mine");

        // act
        var response = await key.PutAsync(
            $"{V1}/documents/{document.Id}/block-order",
            Json(new { blockIds = new[] { own.Id, dmBlock.Id } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await GetDocumentAsync(dmKey, dmDocument.Id)).Blocks.Select(b => b.Id).Should().Equal(dmBlock.Id);
        (await GetDocumentAsync(key, document.Id)).Blocks.Select(b => b.Id).Should().Equal(own.Id);
    }

    [Fact]
    public async Task BlockOrder_WithABlockFromAnotherCampaign_ChangesNothing()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var otherCampagne = await CreateForeignCampaignAsync();
        await AddCharacterAsync(hero, otherCampagne);
        var key = await CreateKeyAsync(hero);
        var elsewhere = await CreateDocumentAsync(key, otherCampagne.Id.Value, "Other table", "Misc");
        var foreignBlock = await CreateBlockAsync(key, elsewhere.Id, "other campaign");
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");

        // act
        var response = await key.PutAsync(
            $"{V1}/documents/{document.Id}/block-order",
            Json(new { blockIds = new[] { foreignBlock.Id } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain("another campaign");
        (await GetDocumentAsync(key, elsewhere.Id)).Blocks.Select(b => b.Id).Should().Equal(foreignBlock.Id);
    }

    [Fact]
    public async Task ANewBlock_AfterArranging_GoesToTheEnd()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var first = await CreateBlockAsync(key, document.Id, "first");
        var second = await CreateBlockAsync(key, document.Id, "second");
        (await key.PutAsync($"{V1}/documents/{document.Id}/block-order", Json(new { blockIds = new[] { second.Id, first.Id } })))
            .EnsureSuccessStatusCode();

        // act
        var third = await CreateBlockAsync(key, document.Id, "third");

        // assert
        (await GetDocumentAsync(key, document.Id)).Blocks.Select(b => b.Id).Should().Equal(second.Id, first.Id, third.Id);
    }

    [Fact]
    public async Task ChangingABlockInTheApp_KeepsItsPlace()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var first = await CreateBlockAsync(key, document.Id, "first");
        var second = await CreateBlockAsync(key, document.Id, "second");
        (await key.PutAsync($"{V1}/documents/{document.Id}/block-order", Json(new { blockIds = new[] { second.Id, first.Id } })))
            .EnsureSuccessStatusCode();
        var appView = JsonNode.Parse(await hero.AppClient.GetStringAsync($"/Notes/getdocument/{document.Id}"))!;
        var sortIndices = appView["textBlocks"]!.AsArray().Select(b => b!["sortIndex"]!.GetValue<int>()).ToList();
        var appBlock = JsonNode
            .Parse(appView["textBlocks"]!.AsArray().Single(b => b!["markdownText"]!.GetValue<string>() == "second")!.ToJsonString())!
            .AsObject();
        appBlock.Remove("sortIndex"); // an app that does not know the field yet
        appBlock["markdownText"] = "second, edited in the app";

        // act
        var response = await hero.AppClient.PutAsync(
            "/Notes/updatetextblock",
            new StringContent(appBlock.ToJsonString(), System.Text.Encoding.UTF8, "application/json")
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var reloaded = await GetDocumentAsync(key, document.Id);
        reloaded.Blocks.Select(b => b.MarkdownText).Should().Equal("second, edited in the app", "first");
        sortIndices.Should().BeEquivalentTo(new[] { 0, 1 }, "the app reads the position");
    }

    [Fact]
    public async Task AWrite_NamingAnOlderVersion_ChangesNothingAndSaysWhereTheDocumentIs()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var block = await CreateBlockAsync(key, document.Id, "draft");
        var read = await GetDocumentAsync(key, document.Id);

        // someone changes only who may read the block
        (await key.PutAsync($"{V1}/blocks/{block.Id}", Json(new { markdownText = "draft", visibleTo = new[] { dm.Id.Value } })))
            .EnsureSuccessStatusCode();
        var current = await GetDocumentAsync(key, document.Id);

        // act
        var update = await key.PutAsync(
            $"{V1}/blocks/{block.Id}",
            Json(new { markdownText = "overwritten", visibleTo = Array.Empty<Guid>(), expectedLastModifiedAt = read.LastModifiedAt })
        );
        var rename = await key.PutAsync(
            $"{V1}/documents/{document.Id}",
            Json(new { title = "Renamed", groupName = "Heist", expectedLastModifiedAt = read.LastModifiedAt })
        );
        var deleteBlock = await key.DeleteAsync($"{V1}/blocks/{block.Id}?expectedLastModifiedAt={Uri.EscapeDataString(read.LastModifiedAt.ToString("O"))}");
        var deleteDocument = await key.DeleteAsync(
            $"{V1}/documents/{document.Id}?expectedLastModifiedAt={Uri.EscapeDataString(read.LastModifiedAt.ToString("O"))}"
        );
        var order = await key.PutAsync(
            $"{V1}/documents/{document.Id}/block-order",
            Json(new { blockIds = new[] { block.Id }, expectedLastModifiedAt = read.LastModifiedAt })
        );

        // assert
        current.LastModifiedAt.Should().BeAfter(read.LastModifiedAt, "changing who may read a block changes the document");
        foreach (var response in new[] { update, rename, deleteBlock, deleteDocument, order })
        {
            response.StatusCode.Should().Be(HttpStatusCode.Conflict, await response.Content.ReadAsStringAsync());
            var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
            body["error"]!.GetValue<string>().Should().Be(ExternalApiErrors.VersionConflict);
            body["currentLastModifiedAt"]!.GetValue<DateTimeOffset>().Should().BeCloseTo(current.LastModifiedAt, TimeSpan.FromMilliseconds(1));
        }

        var after = await GetDocumentAsync(key, document.Id);
        after.Title.Should().Be("Plans");
        after.Blocks.Should().ContainSingle().Which.VisibleTo.Should().Equal(dm.Id.Value);
        after.Blocks[0].MarkdownText.Should().Be("draft");
    }

    [Fact]
    public async Task AWrite_NamingTheCurrentVersion_Succeeds()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans", "Heist");
        var block = await CreateBlockAsync(key, document.Id, "draft");
        var read = await GetDocumentAsync(key, document.Id);

        // act
        var response = await key.PutAsync(
            $"{V1}/blocks/{block.Id}",
            Json(new { markdownText = "final", visibleTo = Array.Empty<Guid>(), expectedLastModifiedAt = read.LastModifiedAt })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        (await GetDocumentAsync(key, document.Id)).LastModifiedAt.Should().BeAfter(read.LastModifiedAt);
    }

    [Fact]
    public async Task BatchOfBlocks_IsAddedInOrderWithTheGivenReaders()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Chronicle", "World");
        await CreateBlockAsync(key, document.Id, "existing");

        // act
        var response = await key.PostAsync(
            $"{V1}/documents/{document.Id}/blocks/batch",
            Json(
                new
                {
                    blocks = new object[]
                    {
                        new { markdownText = "one", visibleTo = Array.Empty<Guid>() },
                        new { markdownText = "two", visibleTo = new[] { dm.Id.Value } },
                    },
                }
            )
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        var created = await response.Content.ReadFromJsonAsync<List<ExternalNoteBlockDto>>(JsonOptions);
        created!.Select(b => b.MarkdownText).Should().Equal("one", "two");
        created[0].VisibleTo.Should().BeEmpty();
        created[1].VisibleTo.Should().Equal(dm.Id.Value);
        (await GetDocumentAsync(key, document.Id)).Blocks.Select(b => b.MarkdownText).Should().Equal("existing", "one", "two");
    }

    [Fact]
    public async Task BatchOfBlocks_WithAReaderOutsideTheCampaign_SavesNothing()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Chronicle", "World");
        var stranger = Guid.NewGuid();

        // act
        var response = await key.PostAsync(
            $"{V1}/documents/{document.Id}/blocks/batch",
            Json(
                new
                {
                    blocks = new object[]
                    {
                        new { markdownText = "fine", visibleTo = Array.Empty<Guid>() },
                        new { markdownText = "leak", visibleTo = new[] { stranger } },
                    },
                }
            )
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain("blocks[1].visibleTo");
        (await GetDocumentAsync(key, document.Id)).Blocks.Should().BeEmpty();
    }

    [Fact]
    public async Task MoveDocuments_PutsThemIntoTheFolderWithoutTouchingTheirBlocks()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var first = await CreateDocumentAsync(key, campagne.Id.Value, "Tavern", "Places");
        var second = await CreateDocumentAsync(key, campagne.Id.Value, "Harbour", "Misc");
        var shared = await CreateBlockAsync(key, first.Id, "The innkeeper lies", dm.Id.Value);

        // act
        var response = await key.PostAsync(
            $"{V1}/campaigns/{campagne.Id.Value}/documents/move",
            Json(new { documentIds = new[] { first.Id, second.Id }, groupName = " Town " })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var moved = await response.Content.ReadFromJsonAsync<List<ExternalNoteDocumentDto>>(JsonOptions);
        moved!.Select(d => d.GroupName).Should().AllBe("Town");
        var reloaded = await GetDocumentAsync(key, first.Id);
        reloaded.GroupName.Should().Be("Town");
        reloaded.Blocks.Should().ContainSingle().Which.Id.Should().Be(shared.Id);
        reloaded.Blocks[0].VisibleTo.Should().Equal(dm.Id.Value);
    }

    [Fact]
    public async Task MoveDocuments_WithSomeoneElsesDocument_MovesNothing()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateKeyAsync(hero);
        var own = await CreateDocumentAsync(key, campagne.Id.Value, "Tavern", "Places");
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead, ApiKeyScopes.NotesWrite);
        var dmDocument = await CreateDocumentAsync(dmKey, campagne.Id.Value, "Lore", "World");
        await CreateBlockAsync(dmKey, dmDocument.Id, "Shared lore", hero.User.Id.Value);

        // act
        var response = await key.PostAsync(
            $"{V1}/campaigns/{campagne.Id.Value}/documents/move",
            Json(new { documentIds = new[] { own.Id, dmDocument.Id }, groupName = "Mine now" })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await GetDocumentAsync(key, own.Id)).GroupName.Should().Be("Places");
        (await GetDocumentAsync(dmKey, dmDocument.Id)).GroupName.Should().Be("World");
    }

    private static async Task<ExternalNoteDocumentDto> GetDocumentAsync(HttpClient key, Guid documentId) =>
        (await key.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{documentId}", JsonOptions))!;

    private static async Task<ExternalNoteDocumentDto> CreateDocumentAsync(HttpClient key, Guid campaignId, string title, string groupName)
    {
        var response = await key.PostAsync($"{V1}/campaigns/{campaignId}/documents", Json(new { title, groupName }));
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteDocumentDto>(JsonOptions))!;
    }

    private static async Task<ExternalNoteBlockDto> CreateBlockAsync(HttpClient key, Guid documentId, string text, params Guid[] visibleTo)
    {
        var response = await key.PostAsync($"{V1}/documents/{documentId}/blocks", Json(new { markdownText = text, visibleTo }));
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions))!;
    }

    private static async Task<ExternalNoteBlockDto> CreateImageBlockAsync(HttpClient key, Guid documentId, string caption, params Guid[] visibleTo)
    {
        var file = new ByteArrayContent(PngBytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        var form = new MultipartFormDataContent
        {
            { file, "image", "map.png" },
            { new StringContent(JsonSerializer.Serialize(visibleTo)), "visibleTo" },
            { new StringContent(caption), "markdownText" },
        };
        var response = await key.PostAsync($"{V1}/documents/{documentId}/image-blocks", form);
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions))!;
    }

    private async Task<HttpClient> CreateKeyAsync(TablePlayer player) =>
        await CreateApiKeyClientAsync(player.User, ApiKeyScopes.NotesRead, ApiKeyScopes.NotesWrite);

    private async Task AddCharacterAsync(TablePlayer player, RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.Campagne campagne)
    {
        using var context = ContextFactory!.CreateDbContext();
        await context.PlayerCharacters.AddAsync(
            new RPGTableHelper.DataLayer.Entities.RpgEntities.PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Second",
                PlayerUserId = player.User.Id.Value,
                CampagneId = campagne.Id.Value,
                RpgCharacterConfiguration = "{}",
                RpgCharacterConfigurationRevision = 1,
            }
        );
        await context.SaveChangesAsync();
    }
}
