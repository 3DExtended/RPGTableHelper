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
/// Notes through the player API: every block says who besides its author may read it, writes must say so, and
/// reads never show a block that was not shared with the reader.
/// </summary>
public class ExternalNotesControllerTests : ExternalApiTestBase
{
    private const string ReadWrite = ApiKeyScopes.NotesWrite;

    private static readonly byte[] PngBytes = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x01 };

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

    [Fact]
    public async Task AnImageBlockSharedWithTheDm_IsReadByTheDmButNotByAnotherPlayer()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var block = await CreateImageBlockAsync(key, document.Id, "The vault", dm.Id.Value);

        // assert
        block.Type.Should().Be("image");
        block.MarkdownText.Should().Be("The vault");
        block.VisibleTo.Should().Equal(dm.Id.Value);
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead);
        var dmView = await dmKey.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        dmView!.Blocks.Should().ContainSingle().Which.ImageUrl.Should().Be(block.ImageUrl);
        var rogueKey = await CreateApiKeyClientAsync(rogue.User, ApiKeyScopes.NotesRead);
        (await rogueKey.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task AnImageBlock_HasAFullUrlThatServesTheImage_AndARelativeOneInTheApp()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var block = await CreateImageBlockAsync(key, document.Id, null, dm.Id.Value);
        var image = await Factory.CreateClient().GetAsync(block.ImageUrl);
        var viaApp = JsonNode.Parse(await Client.GetStringAsync($"/Notes/getdocument/{document.Id}"))!;

        // assert
        block.ImageUrl.Should().StartWith("http://localhost/public/getimage/");
        image.StatusCode.Should().Be(HttpStatusCode.OK);
        (await image.Content.ReadAsByteArrayAsync()).Should().Equal(PngBytes);
        viaApp["imageBlocks"]![0]!["publicImageUrl"]!.GetValue<string>().Should().StartWith("/public/getimage/");
    }

    [Fact]
    public async Task AnImageUrl_BehindTheHttpsTunnel_IsHttps()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        await CreateImageBlockAsync(key, document.Id, null);
        key.DefaultRequestHeaders.Add("X-Forwarded-Proto", "https");

        // act
        var view = await key.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);

        // assert
        view!.Blocks.Should().ContainSingle().Which.ImageUrl.Should().StartWith("https://localhost/public/getimage/");
    }

    [Fact]
    public async Task CreateImageBlock_WithEmptyVisibleTo_IsPrivate()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var block = await CreateImageBlockAsync(key, document.Id, null);

        // assert
        block.VisibleTo.Should().BeEmpty();
        block.MarkdownText.Should().BeNull();
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead);
        (await dmKey.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("not json")]
    [InlineData("null")]
    [InlineData("[\"no-guid\"]")]
    public async Task CreateImageBlock_WithoutValidVisibleTo_IsRejected(string? visibleTo)
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");

        // act
        var response = await key.PostAsync($"{V1}/documents/{document.Id}/image-blocks", ImageForm(PngBytes, "a.png", visibleTo));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.InvalidRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain("isibleTo");
    }

    [Fact]
    public async Task CreateImageBlock_SharedWithSomeoneOutsideTheCampaign_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var stranger = Guid.NewGuid();

        // act
        var response = await key.PostAsync(
            $"{V1}/documents/{document.Id}/image-blocks",
            ImageForm(PngBytes, "a.png", JsonSerializer.Serialize(new[] { stranger }))
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain(stranger.ToString());
    }

    [Fact]
    public async Task CreateImageBlock_WithAFileThatIsNoImage_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var html = "<html></html>"u8.ToArray();

        // act
        var response = await key.PostAsync($"{V1}/documents/{document.Id}/image-blocks", ImageForm(html, "a.png", "[]"));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.InvalidRequest);
    }

    [Fact]
    public async Task CreateImageBlock_InSomeoneElsesDocument_IsForbiddenIfYouCanReadItAndNotFoundOtherwise()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        await CreateBlockAsync(key, document.Id, "For the DM", dm.Id.Value);
        var url = $"{V1}/documents/{document.Id}/image-blocks";

        // act
        var dmResponse = await (await CreateApiKeyClientAsync(dm, ReadWrite)).PostAsync(url, ImageForm(PngBytes, "a.png", "[]"));
        var rogueResponse = await (await CreateApiKeyClientAsync(rogue.User, ReadWrite)).PostAsync(url, ImageForm(PngBytes, "a.png", "[]"));

        // assert
        dmResponse.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        rogueResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreateImageBlock_WithAReadOnlyKey_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var writer = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(writer, campagne.Id.Value, "Plans");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead);

        // act
        var response = await key.PostAsync($"{V1}/documents/{document.Id}/image-blocks", ImageForm(PngBytes, "a.png", "[]"));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task UpdateImageBlock_ChangesCaptionAndReaders_AndKeepsTheImage()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateImageBlockAsync(key, document.Id, "The vault", dm.Id.Value);

        // act
        var response = await key.PutAsync(
            $"{V1}/image-blocks/{block.Id}",
            Json(new { markdownText = "The empty vault", visibleTo = Array.Empty<Guid>() })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var updated = await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions);
        updated!.MarkdownText.Should().Be("The empty vault");
        updated.VisibleTo.Should().BeEmpty();
        updated.ImageUrl.Should().Be(block.ImageUrl);
        (await Factory.CreateClient().GetAsync(updated.ImageUrl)).StatusCode.Should().Be(HttpStatusCode.OK);
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesRead);
        (await dmKey.GetAsync($"{V1}/documents/{document.Id}")).StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task UpdateImageBlock_OfSomeoneElse_IsForbiddenIfYouCanReadItAndNotFoundOtherwise()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateImageBlockAsync(key, document.Id, "For the DM", dm.Id.Value);
        var change = Json(new { markdownText = "Hacked", visibleTo = Array.Empty<Guid>() });

        // act
        var dmResponse = await (await CreateApiKeyClientAsync(dm, ReadWrite)).PutAsync($"{V1}/image-blocks/{block.Id}", change);
        var rogueResponse = await (await CreateApiKeyClientAsync(rogue.User, ReadWrite)).PutAsync($"{V1}/image-blocks/{block.Id}", change);

        // assert
        dmResponse.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        rogueResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task EachBlockType_IsOnlyChangedThroughItsOwnRoute()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var text = await CreateBlockAsync(key, document.Id, "Text");
        var image = await CreateImageBlockAsync(key, document.Id, "Image");
        var change = Json(new { markdownText = "Changed", visibleTo = Array.Empty<Guid>() });

        // act
        var textAsImage = await key.PutAsync($"{V1}/image-blocks/{text.Id}", change);
        var imageAsText = await key.PutAsync($"{V1}/blocks/{image.Id}", change);

        // assert
        textAsImage.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(textAsImage)).Should().Be(ExternalApiErrors.UnsupportedBlockType);
        imageAsText.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(imageAsText)).Should().Be(ExternalApiErrors.UnsupportedBlockType);
    }

    [Fact]
    public async Task DeleteBlock_RemovesAnImageBlock()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead, ReadWrite);
        var document = await CreateDocumentAsync(key, campagne.Id.Value, "Plans");
        var block = await CreateImageBlockAsync(key, document.Id, "Gone soon");

        // act
        var response = await key.DeleteAsync($"{V1}/blocks/{block.Id}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
        var reloaded = await key.GetFromJsonAsync<ExternalNoteDocumentDto>($"{V1}/documents/{document.Id}", JsonOptions);
        reloaded!.Blocks.Should().BeEmpty();
    }

    private static MultipartFormDataContent ImageForm(byte[] bytes, string fileName, string? visibleTo, string? caption = null)
    {
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        var form = new MultipartFormDataContent { { file, "image", fileName } };
        if (visibleTo != null)
        {
            form.Add(new StringContent(visibleTo), "visibleTo");
        }

        if (caption != null)
        {
            form.Add(new StringContent(caption), "markdownText");
        }

        return form;
    }

    private static async Task<ExternalNoteBlockDto> CreateImageBlockAsync(
        HttpClient key,
        Guid documentId,
        string? caption,
        params Guid[] visibleTo
    )
    {
        var response = await key.PostAsync(
            $"{V1}/documents/{documentId}/image-blocks",
            ImageForm(PngBytes, "image.png", JsonSerializer.Serialize(visibleTo), caption)
        );
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalNoteBlockDto>(JsonOptions))!;
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
