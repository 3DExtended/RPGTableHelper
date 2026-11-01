using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.Fights;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

/// <summary>
/// Persisted fights: every character and companion the DM picks is asked to roll, online or not, until they
/// rolled or the DM ends the fight. Players only see their own participants.
/// </summary>
public class FightControllerTests : ControllerTestBase
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
    };

    public FightControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task Start_AsksEveryChosenCharacterAndCompanion_EvenIfTheirPlayerIsOffline()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", ("wolf-uuid", "Wolf"));
        var rogue = await AddPlayerAsync(campagne, "Rogue");

        // act
        var fight = await StartAsync(campagne, Participant(hero), Participant("wolf-uuid"), Participant(rogue));

        // assert
        fight.IsDmView.Should().BeTrue();
        fight.IsOpen.Should().BeTrue();
        fight.Participants.Should().HaveCount(3).And.OnlyContain(p => p.IsPending && p.Roll == null);
        fight.Participants.Single(p => p.CharacterUuid == "wolf-uuid").Kind.Should().Be(FightParticipantKind.Companion);
        fight.Participants.Single(p => p.CharacterUuid == "wolf-uuid").Name.Should().Be("Wolf");
        fight.Participants.Single(p => p.CharacterUuid == hero.Uuid).PlayerCharacterId.Should().Be(hero.CharacterId);
    }

    [Fact]
    public async Task Start_WithACharacterFromAnotherCampagne_ReturnsBadRequest()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var otherCampagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm, joinCode: "other-1");
        var stranger = await AddPlayerAsync(otherCampagne, "Stranger");

        // act
        var response = await Client.PostAsJsonAsync(
            $"/Fight/start/{campagne.Id.Value}",
            new StartFightRequestDto { Participants = new() { Participant(stranger) } }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain(stranger.Uuid);
    }

    [Fact]
    public async Task Start_ByAPlayer_ReturnsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");

        // act
        var response = await hero.Client.PostAsJsonAsync(
            $"/Fight/start/{campagne.Id.Value}",
            new StartFightRequestDto { Participants = new() { Participant(hero) } }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Start_EndsTheFightThatWasStillOpen()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var first = await StartAsync(campagne, Participant(hero));

        // act
        var second = await StartAsync(campagne, Participant(hero));

        // assert
        (await GetCurrentAsync(Client, campagne))!.Id.Should().Be(second.Id);
        using var context = ContextFactory!.CreateDbContext();
        var ended = await context.Fights.SingleAsync(f => f.Id == first.Id);
        ended.EndedAt.Should().NotBeNull();
        ended.EndReason.Should().Be(FightEndReason.ReplacedByNewFight);
    }

    [Fact]
    public async Task Current_ForAPlayer_ShowsOnlyTheirOwnParticipants()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", ("wolf-uuid", "Wolf"));
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        await StartAsync(
            campagne,
            new[] { Participant(hero), Participant("wolf-uuid"), Participant(rogue) },
            new FightEnemyDto { Name = "Goblin", Roll = 14 }
        );

        // act
        var fight = await GetCurrentAsync(hero.Client, campagne);

        // assert
        fight!.IsDmView.Should().BeFalse();
        fight.Participants.Select(p => p.Name).Should().BeEquivalentTo("Hero", "Wolf");
        fight.Participants.Should().OnlyContain(p => p.Position == null);
    }

    [Fact]
    public async Task Current_WithoutAnOpenFight_ReturnsNull()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");

        // act
        var response = await hero.Client.GetFromJsonAsync<CurrentFightResponseDto>(
            $"/Fight/current/{campagne.Id.Value}",
            JsonOptions
        );

        // assert
        response!.Fight.Should().BeNull();
    }

    [Fact]
    public async Task Current_ForSomeoneOutsideTheCampagne_ReturnsNotFound()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var otherCampagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm, joinCode: "other-1");
        var stranger = await AddPlayerAsync(otherCampagne, "Stranger");

        // act
        var response = await stranger.Client.GetAsync($"/Fight/current/{campagne.Id.Value}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Rolls_ArePlacedByRoll_HighestFirst_AndANewTieGoesFirst()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", ("wolf-uuid", "Wolf"));
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var fight = await StartAsync(
            campagne,
            new[] { Participant(hero), Participant("wolf-uuid"), Participant(rogue) },
            new FightEnemyDto { Name = "Goblin", Roll = 15 }
        );

        // act
        var heroView = await RollAsync(hero, fight, (hero.Uuid, 12), ("wolf-uuid", 9));
        await RollAsync(rogue, fight, (rogue.Uuid, 15));

        // assert
        heroView.Participants.Should().OnlyContain(p => !p.IsPending);
        var dmView = await GetCurrentAsync(Client, campagne);
        dmView!.Participants.OrderBy(p => p.Position).Select(p => p.Name).Should().Equal("Rogue", "Goblin", "Hero", "Wolf");
        dmView.Participants.Should().OnlyContain(p => !p.IsPending);
    }

    [Fact]
    public async Task Rolls_ForSomeoneElsesCharacter_AreForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var fight = await StartAsync(campagne, Participant(hero), Participant(rogue));

        // act
        var response = await PostRollsAsync(rogue.Client, fight, (hero.Uuid, 20));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await GetCurrentAsync(hero.Client, campagne))!.Participants.Single().IsPending.Should().BeTrue();
    }

    [Fact]
    public async Task Rolls_Twice_AreAConflict_AndKeepTheFirstRoll()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));
        await RollAsync(hero, fight, (hero.Uuid, 11));

        // act
        var response = await PostRollsAsync(hero.Client, fight, (hero.Uuid, 19));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        (await GetCurrentAsync(hero.Client, campagne))!.Participants.Single().Roll.Should().Be(11);
    }

    [Fact]
    public async Task Rolls_ForSomeoneNotInTheFight_AreABadRequest()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));

        // act
        var response = await PostRollsAsync(hero.Client, fight, ("not-in-fight", 10));

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Reorder_SetsTheOrder_AndRejectsAnIncompleteList()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(
            campagne,
            new[] { Participant(hero) },
            new FightEnemyDto { Name = "Goblin", Roll = 15 },
            new FightEnemyDto { Name = "Orc", Roll = 5 }
        );
        await RollAsync(hero, fight, (hero.Uuid, 10));
        var ids = (await GetCurrentAsync(Client, campagne))!.Participants.OrderBy(p => p.Position).Select(p => p.Id).ToList();

        // act
        var reordered = await Client.PutAsJsonAsync(
            $"/Fight/{fight.Id}/order",
            new ReorderFightRequestDto { ParticipantIds = new() { ids[2], ids[0], ids[1] } }
        );
        var incomplete = await Client.PutAsJsonAsync(
            $"/Fight/{fight.Id}/order",
            new ReorderFightRequestDto { ParticipantIds = new() { ids[0], ids[1] } }
        );

        // assert
        reordered.StatusCode.Should().Be(HttpStatusCode.OK);
        incomplete.StatusCode.Should().Be(HttpStatusCode.Conflict);
        (await GetCurrentAsync(Client, campagne))!
            .Participants.OrderBy(p => p.Position)
            .Select(p => p.Name)
            .Should()
            .Equal("Orc", "Goblin", "Hero");
    }

    [Fact]
    public async Task AddEnemies_PlacesThemByRoll()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));
        await RollAsync(hero, fight, (hero.Uuid, 10));

        // act
        var response = await Client.PostAsJsonAsync(
            $"/Fight/{fight.Id}/enemies",
            new AddFightEnemiesRequestDto
            {
                Enemies = new() { new() { Name = "Dragon", Roll = 22 }, new() { Name = "Rat", Roll = 2 } },
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var updated = await response.Content.ReadFromJsonAsync<FightDto>(JsonOptions);
        updated!.Participants.OrderBy(p => p.Position).Select(p => p.Name).Should().Equal("Dragon", "Hero", "Rat");
    }

    [Fact]
    public async Task RemoveParticipant_StopsAskingThatPlayer()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var fight = await StartAsync(campagne, Participant(hero), Participant(rogue));
        var rogueParticipant = fight.Participants.Single(p => p.Name == "Rogue");

        // act
        var response = await Client.DeleteAsync($"/Fight/{fight.Id}/participants/{rogueParticipant.Id}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        (await GetCurrentAsync(rogue.Client, campagne))!.Participants.Should().BeEmpty();
    }

    [Fact]
    public async Task End_StopsAskingEveryone_AndIsIdempotent()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));

        // act
        var ended = await Client.PostAsync($"/Fight/{fight.Id}/end", null);
        var endedAgain = await Client.PostAsync($"/Fight/{fight.Id}/end", null);
        var lateRoll = await PostRollsAsync(hero.Client, fight, (hero.Uuid, 10));

        // assert
        ended.StatusCode.Should().Be(HttpStatusCode.OK);
        var endedFight = await ended.Content.ReadFromJsonAsync<FightDto>(JsonOptions);
        endedFight!.IsOpen.Should().BeFalse();
        endedFight.EndReason.Should().Be(FightEndReason.EndedByDm);
        endedAgain.StatusCode.Should().Be(HttpStatusCode.OK);
        lateRoll.StatusCode.Should().Be(HttpStatusCode.Conflict);
        (await GetCurrentAsync(hero.Client, campagne)).Should().BeNull();
    }

    [Fact]
    public async Task End_ByAPlayer_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));

        // act
        var response = await hero.Client.PostAsync($"/Fight/{fight.Id}/end", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task AFightWithoutChangesForTwelveHours_IsOver()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));
        using (var context = ContextFactory!.CreateDbContext())
        {
            var entity = await context.Fights.SingleAsync(f => f.Id == fight.Id);
            entity.LastActivityAt = SystemClock.Now - FightService.InactivityTimeout - TimeSpan.FromMinutes(1);
            await context.SaveChangesAsync();
        }

        // act
        var current = await GetCurrentAsync(hero.Client, campagne);
        var lateRoll = await PostRollsAsync(hero.Client, fight, (hero.Uuid, 10));

        // assert
        current.Should().BeNull();
        lateRoll.StatusCode.Should().Be(HttpStatusCode.Conflict);
        using var verify = ContextFactory!.CreateDbContext();
        (await verify.Fights.SingleAsync(f => f.Id == fight.Id)).EndReason.Should().Be(FightEndReason.Expired);
    }

    [Fact]
    public async Task Start_AsksEachPlayerOverSse_ForTheirOwnParticipantsOnly()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero", ("wolf-uuid", "Wolf"));
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        using var heroEvents = await OpenEventsStreamAsync(hero.Client);

        // act
        var fight = await StartAsync(campagne, Participant(hero), Participant("wolf-uuid"), Participant(rogue));

        // assert
        var data = await ReadUntilEventAsync(heroEvents, FightEvents.InitiativeRequested);
        using var payload = JsonDocument.Parse(data);
        payload.RootElement.GetProperty("fightId").GetGuid().Should().Be(fight.Id);
        payload.RootElement.GetProperty("participants")
            .EnumerateArray()
            .Select(p => p.GetProperty("characterUuid").GetString())
            .Should()
            .BeEquivalentTo(hero.Uuid, "wolf-uuid");
    }

    [Fact]
    public async Task Rolls_TellTheDmToReload_AndEndTellsThePlayers()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        using var dmEvents = await OpenEventsStreamAsync(Client);
        using var heroEvents = await OpenEventsStreamAsync(hero.Client);
        var fight = await StartAsync(campagne, Participant(hero));

        // act
        await RollAsync(hero, fight, (hero.Uuid, 13));
        var updated = await ReadUntilEventAsync(dmEvents, FightEvents.FightUpdated);
        await Client.PostAsync($"/Fight/{fight.Id}/end", null);
        var ended = await ReadUntilEventAsync(heroEvents, FightEvents.FightEnded);

        // assert
        updated.Should().Contain(fight.Id.ToString());
        ended.Should().Contain(fight.Id.ToString()).And.Contain("EndedByDm");
    }

    [Fact]
    public async Task LegacyAskForRolls_PersistsTheFight_SoPlayersWhoComeBackAreStillAsked()
    {
        // arrange: an older DM app still uses the pre-persistence endpoint.
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fightUuid = Guid.NewGuid();

        // act
        var response = await Client.PostAsJsonAsync(
            $"/SessionCommand/askplayersforrolls/{campagne.Id.Value}",
            new FightSequenceDto
            {
                FightUuid = fightUuid.ToString(),
                Sequence = new() { new() { CharacterId = hero.Uuid, CharacterName = "Hero", Roll = -1 } },
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var fight = await GetCurrentAsync(hero.Client, campagne);
        fight!.Id.Should().Be(fightUuid);
        fight.Participants.Single().IsPending.Should().BeTrue();
    }

    [Fact]
    public async Task LegacyRollAnswer_IsRecordedInThePersistedFight()
    {
        // arrange: a newer DM app started the fight, the player still runs an older app.
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var fight = await StartAsync(campagne, Participant(hero));

        // act
        var response = await hero.Client.PostAsJsonAsync(
            $"/SessionCommand/sendfightsequencerollstodm/{hero.CharacterId}",
            new FightSequenceDto
            {
                FightUuid = fight.Id.ToString(),
                Sequence = new() { new() { CharacterId = hero.Uuid, CharacterName = "Hero", Roll = 17 } },
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var dmView = await GetCurrentAsync(Client, campagne);
        dmView!.Participants.Single().Roll.Should().Be(17);
        dmView.Participants.Single().Position.Should().Be(0);
    }

    private static StartFightParticipantDto Participant(TablePlayer player) =>
        new() { CharacterUuid = player.Uuid, PlayerCharacterId = player.CharacterId };

    private static StartFightParticipantDto Participant(string characterUuid) => new() { CharacterUuid = characterUuid };

    private static async Task<StreamReader> OpenEventsStreamAsync(HttpClient client)
    {
        var response = await client.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);
        response.EnsureSuccessStatusCode();
        var reader = new StreamReader(await response.Content.ReadAsStreamAsync(), Encoding.UTF8);

        // drain hello
        await reader.ReadLineAsync();
        await reader.ReadLineAsync();
        await reader.ReadLineAsync();
        return reader;
    }

    /// <summary>Skips other events until <paramref name="eventType"/> arrives and returns its data.</summary>
    private static async Task<string> ReadUntilEventAsync(StreamReader reader, string eventType)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(5));
        while (true)
        {
            var line = await reader.ReadLineAsync(timeout.Token);
            line.Should().NotBeNull("the event stream should stay open");
            if (line == $"event: {eventType}")
            {
                var data = await reader.ReadLineAsync(timeout.Token);
                return data!["data: ".Length..];
            }
        }
    }

    private static Task<HttpResponseMessage> PostRollsAsync(
        HttpClient client,
        FightDto fight,
        params (string Uuid, int Roll)[] rolls
    ) =>
        client.PostAsJsonAsync(
            $"/Fight/{fight.Id}/rolls",
            new SubmitFightRollsRequestDto
            {
                Rolls = rolls.Select(r => new FightRollDto { CharacterUuid = r.Uuid, Roll = r.Roll }).ToList(),
            }
        );

    private static async Task<FightDto> RollAsync(TablePlayer player, FightDto fight, params (string Uuid, int Roll)[] rolls)
    {
        var response = await PostRollsAsync(player.Client, fight, rolls);
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<FightDto>(JsonOptions))!;
    }

    private static async Task<FightDto?> GetCurrentAsync(HttpClient client, Campagne campagne)
    {
        var response = await client.GetFromJsonAsync<CurrentFightResponseDto>(
            $"/Fight/current/{campagne.Id.Value}",
            JsonOptions
        );
        return response!.Fight;
    }

    private async Task<(User Dm, Campagne Campagne)> CreateTableAsync()
    {
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);
        return (dm, campagne);
    }

    private async Task<TablePlayer> AddPlayerAsync(
        Campagne campagne,
        string characterName,
        params (string Uuid, string Name)[] companions
    )
    {
        var user = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory!,
            Mapper!,
            usernameOverride: characterName + "Player"
        );
        var uuid = Guid.NewGuid().ToString();
        var config = new JsonObject
        {
            ["uuid"] = uuid,
            ["characterName"] = characterName,
            ["companionCharacters"] = new JsonArray(
                companions
                    .Select(c => (JsonNode)new JsonObject { ["uuid"] = c.Uuid, ["characterName"] = c.Name })
                    .ToArray()
            ),
        };

        var character = new PlayerCharacterEntity
        {
            Id = Guid.NewGuid(),
            CharacterName = characterName,
            PlayerUserId = user.Id.Value,
            CampagneId = campagne.Id.Value,
            RpgCharacterConfiguration = config.ToJsonString(),
        };
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(character);
            await context.SaveChangesAsync();
        }

        var client = Factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", CreateJwtForUser(user));
        return new TablePlayer(user, client, character.Id, uuid);
    }

    private Task<FightDto> StartAsync(Campagne campagne, params StartFightParticipantDto[] participants) =>
        StartAsync(campagne, participants, Array.Empty<FightEnemyDto>());

    private async Task<FightDto> StartAsync(
        Campagne campagne,
        StartFightParticipantDto[] participants,
        params FightEnemyDto[] enemies
    )
    {
        var response = await Client.PostAsJsonAsync(
            $"/Fight/start/{campagne.Id.Value}",
            new StartFightRequestDto { Participants = participants.ToList(), Enemies = enemies.ToList() }
        );
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<FightDto>(JsonOptions))!;
    }

    private sealed class TablePlayer
    {
        public TablePlayer(User user, HttpClient client, Guid characterId, string uuid)
        {
            User = user;
            Client = client;
            CharacterId = characterId;
            Uuid = uuid;
        }

        public User User { get; }

        public HttpClient Client { get; }

        public Guid CharacterId { get; }

        public string Uuid { get; }
    }
}
