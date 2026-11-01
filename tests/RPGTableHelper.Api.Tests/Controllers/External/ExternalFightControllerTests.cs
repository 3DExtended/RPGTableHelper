using System.Net;
using System.Net.Http.Json;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Dtos.Fights;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// Initiative through the player API: a client sees the DM's open fight with its own pending participants and
/// rolls for them, even if it was offline when the fight started.
/// </summary>
public class ExternalFightControllerTests : ExternalApiTestBase
{
    public ExternalFightControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task GetFight_ShowsTheOpenFightWithYourPendingParticipantsOnly()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", companionUuid: "wolf-uuid");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        await StartFightAsync(campagne, hero.Uuid, "wolf-uuid", rogue.Uuid);
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);

        // act
        var current = await key.GetFromJsonAsync<CurrentFightResponseDto>(
            $"{V1}/campaigns/{campagne.Id.Value}/fight",
            JsonOptions
        );

        // assert
        current!.Fight!.IsDmView.Should().BeFalse();
        current.Fight.Participants.Select(p => p.CharacterUuid).Should().BeEquivalentTo(hero.Uuid, "wolf-uuid");
        current.Fight.Participants.Should().OnlyContain(p => p.IsPending);
    }

    [Fact]
    public async Task GetFight_WithoutAFight_IsNull()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);

        // act
        var current = await key.GetFromJsonAsync<CurrentFightResponseDto>(
            $"{V1}/campaigns/{campagne.Id.Value}/fight",
            JsonOptions
        );

        // assert
        current!.Fight.Should().BeNull();
    }

    [Fact]
    public async Task Rolls_ReachTheDmsInitiativeOrder()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", companionUuid: "wolf-uuid");
        await StartFightAsync(campagne, hero.Uuid, "wolf-uuid");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);

        // act
        var response = await RollAsync(key, campagne, (hero.Uuid, 17), ("wolf-uuid", 9));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var playerView = await response.Content.ReadFromJsonAsync<FightDto>(JsonOptions);
        playerView!.Participants.Should().OnlyContain(p => !p.IsPending);
        var dmView = await Client.GetFromJsonAsync<CurrentFightResponseDto>(
            $"/Fight/current/{campagne.Id.Value}",
            JsonOptions
        );
        dmView!.Fight!.Participants.OrderBy(p => p.Position).Select(p => p.Roll).Should().Equal(17, 9);
    }

    [Fact]
    public async Task Rolls_ForSomeoneElsesCharacter_AreForbidden_EvenForTheDm()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        await StartFightAsync(campagne, hero.Uuid, rogue.Uuid);
        var heroKey = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.FightsPlay);

        // act
        var heroResponse = await RollAsync(heroKey, campagne, (rogue.Uuid, 20));
        var dmResponse = await RollAsync(dmKey, campagne, (hero.Uuid, 20));

        // assert
        heroResponse.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await ReadErrorCodeAsync(heroResponse)).Should().Be(ExternalApiErrors.Forbidden);
        dmResponse.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Rolls_Twice_AreAConflict()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        await StartFightAsync(campagne, hero.Uuid);
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);
        (await RollAsync(key, campagne, (hero.Uuid, 12))).EnsureSuccessStatusCode();

        // act
        var response = await RollAsync(key, campagne, (hero.Uuid, 15));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.FightConflict);
    }

    [Fact]
    public async Task Rolls_WithoutAnOpenFight_AreAConflict()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.FightsPlay);

        // act
        var response = await RollAsync(key, campagne, (hero.Uuid, 12));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.NoOpenFight);
    }

    [Fact]
    public async Task Fight_WithoutFightsPlay_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CharactersRead);

        // act
        var response = await key.GetAsync($"{V1}/campaigns/{campagne.Id.Value}/fight");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    private static Task<HttpResponseMessage> RollAsync(
        HttpClient key,
        Campagne campagne,
        params (string Uuid, int Roll)[] rolls
    ) =>
        key.PostAsync(
            $"{V1}/campaigns/{campagne.Id.Value}/fight/rolls",
            Json(new { rolls = rolls.Select(r => new { characterUuid = r.Uuid, roll = r.Roll }) })
        );

    private async Task StartFightAsync(Campagne campagne, params string[] characterUuids)
    {
        var response = await Client.PostAsJsonAsync(
            $"/Fight/start/{campagne.Id.Value}",
            new StartFightRequestDto
            {
                Participants = characterUuids.Select(uuid => new StartFightParticipantDto { CharacterUuid = uuid }).ToList(),
            }
        );
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
    }
}
