using System.Net;
using System.Net.Http.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.External;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// Notes through the player API: every block says who besides its author may read it, writes must say so, and
/// reads never show a block that was not shared with the reader.
/// </summary>
public class ExternalNotesControllerTests : ExternalApiTestBase
{
    private const string ReadWrite = ApiKeyScopes.NotesWrite;

    public ExternalNotesControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task ABlockSharedWithTheDm_IsReadByTheDmButNotByAnotherPlayer()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var block = await CreateBlockAsync(key, document.Id, "Steal the crown", dm.Id.Value);

        // assert
        block.VisibleTo.Should().Equal(dm.Id.Value);
        block.IsOwn.Should().BeTrue();
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead);
        var dmView = await dmKey.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        dmView!.Blocks.Should().ContainSingle().Which.MarkdownText.Should().Be("Steal the crown");
        dmView.Blocks[0].VisibleTo.Should().BeNull("only the author sees who else may read a block");

        var rogueKey = await CreateApiKeyClientAsync(rogue.User, ApiKeyScopes.NotesRead);
        (await rogueKey.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
        var rogueList = await rogueKey.GetFromJsonAsync<List<ExternalNoteDocumentDto>>(
            $"{V1}/campaigns/{campagne.Id.Value}/documents",
            JsonOptions
        );
        rogueList.Should().BeEmpty();
    }

    [Fact]
    public async Task ADocument_ShowsSomeoneElseOnlyTheBlocksSharedWithThem()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Diary");
        await CreateBlockAsync(key, document.Id, "For the DM", dm.Id.Value);
        await CreateBlockAsync(key, document.Id, "Only for me");

        // act
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead);
        var viaApi = await dmKey.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        var viaApp = JsonNode.Parse(await Client.GetStringAsync($"/Notes/getdocument/{document.Id}"))!;
        var viaLegacy = JsonNode.Parse(await dmKey.GetStringAsync($"/api/external/documents/{document.Id}"))!;

        // assert
        viaApi!.Blocks.Select(b => b.MarkdownText).Should().Equal("For the DM");
        viaApp["textBlocks"]!.AsArray().Select(b => b!["markdownText"]!.GetValue<string>()).Should().Equal("For the DM");
        viaLegacy["textBlocks"]!.AsArray().Should().HaveCount(1);
        var own = await key.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        own!.Blocks.Select(b => b.MarkdownText).Should().Equal("For the DM", "Only for me");
    }

    [Fact]
    public async Task CreateBlock_WithoutVisibleTo_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var response = await key.PostAsync($"{V1}/documents/{document.Id}/blocks", Json(new { markdownText = "Hi" }));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        body["error"]!.GetValue<string>().Should().Be(ExternalApiErrors.InvalidRequest);
        body["problems"]!.ToJsonString().Should().Contain("VisibleTo");
    }

    [Fact]
    public async Task CreateBlock_SharedWithSomeoneOutsideTheCampaign_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var stranger = Guid.NewGuid();

        // act
        var response = await key.PostAsync(
            $"{V1}/documents/{document.Id}/blocks",
            Json(new { markdownText = "Hi", visibleTo = new[] { stranger } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain(stranger.ToString());
    }

    [Fact]
    public async Task CreateBlock_SharedWithYourself_IsPrivate()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var block = await CreateBlockAsync(key, document.Id, "Mine", hero.User.Id.Value);

        // assert
        block.VisibleTo.Should().BeEmpty();
    }

    [Fact]
    public async Task UpdateBlock_TakingAReaderOut_HidesTheBlockFromThem()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateBlockAsync(key, document.Id, "Shared", dm.Id.Value, rogue.User.Id.Value);

        // act
        var response = await key.PutAsync(
            $"{V1}/blocks/{block.Id}",
            Json(new { markdownText = "Only the DM now", visibleTo = new[] { dm.Id.Value } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var updated = await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions);
        updated!.MarkdownText.Should().Be("Only the DM now");
        updated.VisibleTo.Should().Equal(dm.Id.Value);
        var rogueKey = await CreateApiKeyClientAsync(rogue.User, ApiKeyScopes.NotesRead);
        (await rogueKey.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task UpdateBlock_OfSomeoneElse_IsForbiddenIfYouCanReadItAndNotFoundOtherwise()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateBlockAsync(key, document.Id, "For the DM", dm.Id.Value);
        var change = Json(new { markdownText = "Hacked", visibleTo = Array.Empty<Guid>() });

        // act
        var dmResponse = await (await CreateApiKeyClientAsync(dm, ReadWrite)).PutAsync($"{V1}/blocks/{block.Id}", change);
        var rogueResponse = await (await CreateApiKeyClientAsync(rogue.User, ReadWrite)).PutAsync($"{V1}/blocks/{block.Id}", change);

        // assert
        dmResponse.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await ReadErrorCodeAsync(dmResponse)).Should().Be(ExternalApiErrors.Forbidden);
        rogueResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task UpdateAndDeleteDocument_WorkForTheAuthor()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var renamed = await key.PutAsync(
            $"{V1}/documents/{document.Id}",
            Json(new { title = "Secret plans", groupName = "Heist" })
        );
        var deleted = await key.DeleteAsync($"{V1}/documents/{document.Id}");

        // assert
        renamed.StatusCode.Should().Be(HttpStatusCode.OK);
        (await renamed.Content.ReadFromJsonAsync<ExternalNoteDocumentDto>(JsonOptions))!
            .Should().BeEquivalentTo(new { Title = "Secret plans", GroupName = "Heist" });
        deleted.StatusCode.Should().Be(HttpStatusCode.NoContent);
        (await key.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeleteBlock_RemovesIt()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateBlockAsync(key, document.Id, "Gone soon");

        // act
        var response = await key.DeleteAsync($"{V1}/blocks/{block.Id}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
        var reloaded = await key.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        reloaded!.Blocks.Should().BeEmpty();
    }

    [Fact]
    public async Task Writing_WithAReadOnlyKey_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead);

        // act
        var response = await key.PostAsync(
            $"{V1}/campaigns/{campagne.Id.Value}/documents",
            Json(new { title = "Plans", groupName = "Heist" })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task CreateDocument_InACampaignYouAreNotIn_IsNotFound()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var otherCampagne = await CreateForeignCampaignAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);

        // act
        var response = await key.PostAsync(
            $"{V1}/campaigns/{otherCampagne.Id.Value}/documents",
            Json(new { title = "Plans", groupName = "Heist" })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    private static async Task<ExternalNoteDocumentDto> CreateDocumentAsync(HttpClient key, Guid campaignId, string title)
    {
        var response = await key.PostAsync(
            $"{V1}/campaigns/{campaignId}/documents",
            Json(new { title, groupName = "Adventure" })
        );
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteDocumentDto>(JsonOptions))!;
    }

    private static async Task<ExternalNoteBlockDto> CreateBlockAsync(
        HttpClient key,
        Guid documentId,
        string text,
        params Guid[] visibleTo
    )
    {
        var response = await key.PostAsync(
            $"{V1}/documents/{documentId}/blocks",
            Json(new { markdownText = text, visibleTo })
        );
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions))!;
    }
}
