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
/// Sheets through the player API: every write is revision-checked, validated against the campaign's stat types
/// and announced to the table, so the DM sees e.g. hit points change.
/// </summary>
public class ExternalCharacterSheetControllerTests : ExternalApiTestBase
{
    public ExternalCharacterSheetControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task GetSheet_ReturnsTheStoredSheetAsAnObject()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead);

        // act
        var body = JsonNode.Parse(await key.GetStringAsync($"{V1}/characters/{hero.CharacterId}/sheet"))!;

        // assert
        body["revision"]!.GetValue<int>().Should().Be(1);
        body["campaignId"]!.GetValue<Guid>().Should().Be(campagne.Id.Value);
        body["sheet"]!["uuid"]!.GetValue<string>().Should().Be(hero.Uuid);
        body["sheet"]!["characterStats"]![1]!["serializedValue"]!.GetValue<string>().Should().Be(HpValue(10, 20));
    }

    [Fact]
    public async Task GetSheet_OfSomeoneElsesCharacter_IsNotFound()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead);

        // act
        var response = await key.GetAsync($"{V1}/characters/{rogue.CharacterId}/sheet");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task PatchSheet_StoresTheChangeAndTellsTheDmAndThePlayersOwnApp()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);
        using var dmEvents = await KeepEventsStreamOpenAsync(Client);
        using var heroAppEvents = await KeepEventsStreamOpenAsync(hero.AppClient);
        (await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).EnsureSuccessStatusCode();
        (await hero.AppClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).EnsureSuccessStatusCode();

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(
                new
                {
                    fromRevision = 1,
                    patch = new object[]
                    {
                        new { op = "replace", path = "/characterStats/1/serializedValue", value = HpValue(7, 20) },
                    },
                }
            )
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        (await response.Content.ReadFromJsonAsync<ExternalCharacterSheetWriteResultDto>(JsonOptions))!
            .Revision.Should().Be(2);
        (await LoadStoredSheetAsync(hero.CharacterId))["characterStats"]![1]!["serializedValue"]!.GetValue<string>()
            .Should().Be(HpValue(7, 20));

        var dmEvent = JsonNode.Parse(await ReadUntilEventAsync(dmEvents, "characterConfigChanged"))!;
        dmEvent["id"]!.GetValue<string>().Should().Be(hero.CharacterId.ToString());
        dmEvent["revision"]!.GetValue<int>().Should().Be(2);
        await ReadUntilEventAsync(heroAppEvents, "characterConfigChanged");
    }

    [Theory]
    [InlineData("PATCH")]
    [InlineData("PUT")]
    public async Task AChangeMadeInThePlayersQuestkeeperApp_ReachesTheirOtherApp(string method)
    {
        // arrange: the player's web app (API key) sits at the table next to their Questkeeper app.
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead, ApiKeyScopes.Events);
        using var webAppEvents = await KeepEventsStreamOpenAsync(key);
        (await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/enter", null)).EnsureSuccessStatusCode();

        // act: the hit points change in the Questkeeper app.
        HttpResponseMessage response;
        if (method == "PATCH")
        {
            var patch = new JsonArray(
                new JsonObject
                {
                    ["op"] = "replace",
                    ["path"] = "/characterStats/1/serializedValue",
                    ["value"] = HpValue(4, 20),
                }
            );
            response = await hero.AppClient.PatchAsync(
                $"/PlayerCharacter/patchcharacterconfig/{hero.CharacterId}",
                Json(new { fromRevision = 1, patch = patch.ToJsonString() })
            );
        }
        else
        {
            var sheet = await LoadStoredSheetAsync(hero.CharacterId);
            sheet["characterStats"]![1]!["serializedValue"] = HpValue(4, 20);
            response = await hero.AppClient.PutAsync(
                $"/PlayerCharacter/updatecharacterconfig/{hero.CharacterId}",
                Json(new { rpgCharacterConfiguration = sheet.ToJsonString(), fromRevision = 1 })
            );
        }

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var changed = JsonNode.Parse(await ReadUntilEventAsync(webAppEvents, "characterConfigChanged"))!;
        changed["id"]!.GetValue<string>().Should().Be(hero.CharacterId.ToString());
        changed["revision"]!.GetValue<int>().Should().Be(2);
    }

    [Fact]
    public async Task PatchSheet_FromAnOldRevision_IsAConflictNamingTheCurrentRevision()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { fromRevision = 0, patch = new object[] { new { op = "replace", path = "/characterName", value = "X" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        body["error"]!.GetValue<string>().Should().Be(ExternalApiErrors.RevisionConflict);
        body["currentRevision"]!.GetValue<int>().Should().Be(1);
    }

    [Fact]
    public async Task PatchSheet_ToAPathThatIsNotThere_IsAnInvalidPatch()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { fromRevision = 1, patch = new object[] { new { op = "replace", path = "/characterStats/9/serializedValue", value = "{}" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.InvalidPatch);
    }

    [Fact]
    public async Task PatchSheet_ThatBreaksAStatValue_IsRejectedWithTheProblemAndNothingIsSaved()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(
                new
                {
                    fromRevision = 1,
                    patch = new object[]
                    {
                        new { op = "replace", path = "/characterStats/1/serializedValue", value = "{\"value\":\"lots\"}" },
                    },
                }
            )
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.UnprocessableEntity);
        var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        body["error"]!.GetValue<string>().Should().Be(ExternalApiErrors.InvalidSheet);
        body["problems"]!.AsArray().Select(p => p!.GetValue<string>())
            .Should().ContainSingle(p => p.Contains($"statUuid={HpStat}"));
        (await LoadStoredSheetAsync(hero.CharacterId))["characterStats"]![1]!["serializedValue"]!.GetValue<string>()
            .Should().Be(HpValue(10, 20));
    }

    [Fact]
    public async Task PatchSheet_ThatChangesTheUuid_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { fromRevision = 1, patch = new object[] { new { op = "replace", path = "/uuid", value = "new-uuid" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.UnprocessableEntity);
    }

    [Fact]
    public async Task PatchSheet_ThatRemovesTheInventory_IsRejectedBecauseTheAppNeedsIt()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { fromRevision = 1, patch = new object[] { new { op = "remove", path = "/inventory" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.UnprocessableEntity);
        var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        body["problems"]!.AsArray().Select(p => p!.GetValue<string>())
            .Should().ContainSingle(p => p.StartsWith("/inventory"));
        (await LoadStoredSheetAsync(hero.CharacterId))["inventory"].Should().NotBeNull();
    }

    [Fact]
    public async Task PatchSheet_WithoutFromRevision_IsAnInvalidRequest()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { patch = new object[] { new { op = "replace", path = "/characterName", value = "X" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var body = JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        body["error"]!.GetValue<string>().Should().Be(ExternalApiErrors.InvalidRequest);
        body["problems"]!.ToJsonString().Should().Contain("FromRevision");
    }

    [Fact]
    public async Task PatchSheet_WithAReadOnlyKey_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead);

        // act
        var response = await key.PatchAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet",
            Json(new { fromRevision = 1, patch = new object[] { new { op = "replace", path = "/characterName", value = "X" } } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await ReadErrorCodeAsync(response)).Should().Be("insufficient_scope");
    }

    [Fact]
    public async Task SetStat_SetsHitPointsWithoutARevision()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/{HpStat}",
            Json(new { value = new { value = 3, maxValue = 20 } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var stored = JsonNode.Parse(
            (await LoadStoredSheetAsync(hero.CharacterId))["characterStats"]![1]!["serializedValue"]!.GetValue<string>()
        )!;
        stored["value"]!.GetValue<int>().Should().Be(3);
        stored["maxValue"]!.GetValue<int>().Should().Be(20);
    }

    [Fact]
    public async Task SetStat_OfACompanion_ChangesOnlyTheCompanion()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", companionUuid: "wolf-uuid");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/{HpStat}?companionUuid=wolf-uuid",
            Json(new { value = new { value = 1, maxValue = 8 } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var sheet = await LoadStoredSheetAsync(hero.CharacterId);
        sheet["companionCharacters"]![0]!["characterStats"]![0]!["serializedValue"]!.GetValue<string>()
            .Should().Be("{\"value\":1,\"maxValue\":8}");
        sheet["characterStats"]![1]!["serializedValue"]!.GetValue<string>().Should().Be(HpValue(10, 20));
    }

    [Fact]
    public async Task SetStat_WhileTransformed_ChangesTheActiveForm()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        await UpdateStoredSheetAsync(
            hero.CharacterId,
            sheet =>
            {
                sheet["isAlternateFormActive"] = true;
                sheet["alternateForm"] = new JsonObject
                {
                    ["uuid"] = "bear-form",
                    ["characterName"] = "Bear",
                    ["characterStats"] = new JsonArray(Stat(HpStat, HpValue(30, 30))),
                };
            }
        );
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/{HpStat}",
            Json(new { value = new { value = 22, maxValue = 30 } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var stored = await LoadStoredSheetAsync(hero.CharacterId);
        stored["alternateForm"]!["characterStats"]![0]!["serializedValue"]!.GetValue<string>()
            .Should().Be("{\"value\":22,\"maxValue\":30}");
        stored["characterStats"]![1]!["serializedValue"]!.GetValue<string>().Should().Be(HpValue(10, 20));
    }

    [Fact]
    public async Task SetStat_WithAValueOfTheWrongType_IsRejected()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/{HpStat}",
            Json(new { value = new { value = "full" } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.UnprocessableEntity);
    }

    [Fact]
    public async Task SetStat_ThatTheSheetDoesNotHave_IsNotFound()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/unknown-stat",
            Json(new { value = new { value = 1 } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task SetStat_WithAStaleRevision_IsAConflict()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersWrite);

        // act
        var response = await key.PutAsync(
            $"{V1}/characters/{hero.CharacterId}/sheet/stats/{HpStat}",
            Json(new { fromRevision = 5, value = new { value = 1, maxValue = 20 } })
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
    }
}
