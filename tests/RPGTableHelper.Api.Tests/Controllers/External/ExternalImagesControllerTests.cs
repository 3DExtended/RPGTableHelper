using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.External;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// Uploading an image through the player API, so a player's own app can set the picture of a
/// <c>singleImage</c> stat as the Questkeeper app does.
/// </summary>
public class ExternalImagesControllerTests : ExternalApiTestBase
{
    private static readonly byte[] PngBytes = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x01 };

    public ExternalImagesControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task UploadImage_ReturnsARelativePathAndAFullUrlThatServeTheImage()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var image = await UploadAsync(key, campagne.Id.Value);
        var served = await Factory.CreateClient().GetAsync(image.ImageUrl);

        // assert
        image.Path.Should().StartWith("/public/getimage/");
        image.ImageUrl.Should().Be("http://localhost" + image.Path);
        served.StatusCode.Should().Be(HttpStatusCode.OK);
        (await served.Content.ReadAsByteArrayAsync()).Should().Equal(PngBytes);
    }

    [Fact]
    public async Task AnUploadedImage_CanBeSetAsTheSingleImageStatOfYourCharacter()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);
        var image = await UploadAsync(key, campagne.Id.Value);
        var value = new JsonObject { ["imageUrl"] = image.Path, ["value"] = "Hero at dawn" }.ToJsonString();

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(
                new
                {
                    fromRevision = 1,
                    patch = new[]
                    {
                        new
                        {
                            op = "add",
                            path = "/characterStats/-",
                            value = new { statUuid = PortraitStat, serializedValue = value },
                        },
                    },
                }
            )
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var stored = await LoadStoredSheetAsync(hero.CharacterId);
        var portrait = stored["characterStats"]!.AsArray().Single(s => s!["statUuid"]!.GetValue<string>() == PortraitStat)!;
        JsonNode.Parse(portrait["serializedValue"]!.GetValue<string>())!["imageUrl"]!.GetValue<string>().Should().Be(image.Path);
    }

    [Fact]
    public async Task UploadImage_BehindTheHttpsTunnel_HasAnHttpsUrl()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);
        key.DefaultRequestHeaders.Add("X-Forwarded-Proto", "https");

        // act
        var image = await UploadAsync(key, campagne.Id.Value);

        // assert
        image.ImageUrl.Should().Be("https://localhost" + image.Path);
    }

    [Fact]
    public async Task UploadImage_WithAFileThatIsNoImage_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/images", ImageForm("<html></html>"u8.ToArray()));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.InvalidRequest);
    }

    [Fact]
    public async Task UploadImage_WithoutAFile_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/images", new MultipartFormDataContent());

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.InvalidRequest);
    }

    [Fact]
    public async Task UploadImage_ToACampaignYouAreNotPartOf_IsNotFound()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var foreign = await CreateForeignCampaignAsync();
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{foreign.Id.Value}/images", ImageForm(PngBytes));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task UploadImage_WithAKeyThatCannotWriteCharacters_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead, ApiKeyScopes.NotesWrite);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/images", ImageForm(PngBytes));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    private static MultipartFormDataContent ImageForm(byte[] bytes)
    {
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        return new MultipartFormDataContent { { file, "image", "portrait.png" } };
    }

    private static async Task<ExternalImageDto> UploadAsync(HttpClient key, Guid campaignId)
    {
        var response = await key.PostAsync($"{V1}/campaigns/{campaignId}/images", ImageForm(PngBytes));
        response.StatusCode.Should().Be(HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<ExternalImageDto>(JsonOptions))!;
    }
}
