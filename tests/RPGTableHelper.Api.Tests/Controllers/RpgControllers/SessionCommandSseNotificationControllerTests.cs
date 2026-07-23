using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

/// <summary>
/// Coverage for sse-06: REST ask-rolls / roll-result endpoints fan out an inline fight-sequence payload over
/// SSE to session participants, and grant-items mutates the character config through the revisioned store
/// (bumping the revision, notifying <c>characterConfigChanged</c>) plus an optional <c>itemsGranted</c>
/// toast to the granted player. All notifies are session-scoped (<c>ISessionPresenceService</c>), not
/// membership-scoped like sse-05's join-request notifies.
/// </summary>
public class SessionCommandSseNotificationControllerTests : ControllerTestBase
{
    public SessionCommandSseNotificationControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task AskPlayersForRollsAsync_NotifiesOtherSessionParticipant_WithInlineFightSequencePayload()
    {
        // arrange: DM (writer) and an accepted player both enter the table session.
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(
                new PlayerCharacterEntity
                {
                    Id = Guid.NewGuid(),
                    CharacterName = "Hero",
                    PlayerUserId = player.Id.Value,
                    CampagneId = campagne.Id.Value,
                }
            );
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var playerReader = await OpenEventsStreamAsync(playerClient);

        (await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);
        (await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        // drain the participantOnline event about the dm entering
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        var fightSequence = new FightSequenceDto
        {
            FightUuid = "fight-1",
            Sequence = new List<FightSequenceEntryDto>
            {
                new() { CharacterId = null, CharacterName = "Goblin", Roll = 0 },
            },
        };

        // act: DM asks for rolls.
        var response = await Client.PostAsJsonAsync($"/SessionCommand/askplayersforrolls/{campagne.Id.Value}", fightSequence);
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert: peer gets the fight sequence inline, no extra round-trip needed.
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: playersAreAskedForRolls");
        dataLine.Should().Contain("fight-1");
        dataLine.Should().Contain("Goblin");
    }

    [Fact]
    public async Task AskPlayersForRollsAsync_Returns401_WhenCallerIsNotDm()
    {
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var notTheDm = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "NotDm");
        using var otherClient = Factory.CreateClient();
        otherClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(notTheDm)
        );

        var fightSequence = new FightSequenceDto { FightUuid = "fight-1", Sequence = new List<FightSequenceEntryDto>() };

        var response = await otherClient.PostAsJsonAsync(
            $"/SessionCommand/askplayersforrolls/{campagne.Id.Value}",
            fightSequence
        );

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task SendFightSequenceRollsToDmAsync_NotifiesDmInSession_WithInlineFightSequencePayload()
    {
        // arrange: DM and the character-owning player both enter the table session.
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        PlayerCharacterEntity characterEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            characterEntity = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Hero",
                PlayerUserId = player.Id.Value,
                CampagneId = campagne.Id.Value,
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var dmReader = await OpenEventsStreamAsync(Client);

        (await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);
        (await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        // drain the participantOnline event about the player entering
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();

        var fightSequence = new FightSequenceDto
        {
            FightUuid = "fight-2",
            Sequence = new List<FightSequenceEntryDto>
            {
                new() { CharacterId = characterEntity.Id.ToString(), CharacterName = "Hero", Roll = 15 },
            },
        };

        // act: player reports their roll.
        var response = await playerClient.PostAsJsonAsync(
            $"/SessionCommand/sendfightsequencerollstodm/{characterEntity.Id}",
            fightSequence
        );
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await dmReader.ReadLineAsync();
        var dataLine = await dmReader.ReadLineAsync();

        eventLine.Should().Be("event: dmReceivedFightSequenceAnswer");
        dataLine.Should().Contain("fight-2");
        dataLine.Should().Contain("15");
    }

    [Fact]
    public async Task SendFightSequenceRollsToDmAsync_DoesNotNotify_WhenDmHasNotEnteredSession()
    {
        // arrange: DM keeps their /events stream open but never enters the session.
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        PlayerCharacterEntity characterEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            characterEntity = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Hero",
                PlayerUserId = player.Id.Value,
                CampagneId = campagne.Id.Value,
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var dmReader = await OpenEventsStreamAsync(Client);

        (await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        var fightSequence = new FightSequenceDto { FightUuid = "fight-3", Sequence = new List<FightSequenceEntryDto>() };

        // act
        var response = await playerClient.PostAsJsonAsync(
            $"/SessionCommand/sendfightsequencerollstodm/{characterEntity.Id}",
            fightSequence
        );
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert: nothing beyond the drained hello arrives on the DM's stream.
        var readTask = dmReader.ReadLineAsync();
        var completed = await Task.WhenAny(readTask, Task.Delay(TimeSpan.FromMilliseconds(300)));
        completed.Should().NotBe(readTask);
    }

    [Fact]
    public async Task GrantItemsAsync_MutatesCharacterConfigAndBumpsRevision_AndNotifiesPeerAndPlayer()
    {
        // arrange: DM and the granted player both enter the table session.
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        PlayerCharacterEntity characterEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            characterEntity = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Hero",
                PlayerUserId = player.Id.Value,
                CampagneId = campagne.Id.Value,
                RpgCharacterConfiguration = "{\"inventory\":[]}",
                RpgCharacterConfigurationRevision = 1,
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var playerReader = await OpenEventsStreamAsync(playerClient);

        // player enters first so the dm's later entry broadcasts participantOnline to them.
        (await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);
        (await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        // drain the participantOnline event about the dm entering
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        var grantRequest = new GrantItemsRequestDto
        {
            Items = new List<GrantedItemDto> { new() { ItemUuid = "item-1", Amount = 3 } },
        };

        // act: DM grants items.
        var response = await Client.PostAsJsonAsync($"/SessionCommand/grantitems/{characterEntity.Id}", grantRequest);
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var writeResult = await response.Content.ReadFromJsonAsync<ConfigWriteResultDto>();
        writeResult!.Revision.Should().Be(2);

        // assert: player is notified with id + revision only (no config body)...
        var configChangedEventLine = await playerReader.ReadLineAsync();
        var configChangedDataLine = await playerReader.ReadLineAsync();

        configChangedEventLine.Should().Be("event: characterConfigChanged");
        configChangedDataLine.Should().Contain(characterEntity.Id.ToString());
        configChangedDataLine.Should().Contain("2");
        configChangedDataLine.Should().NotContain("item-1");

        // drain the blank line separating the two consecutive SSE events.
        await playerReader.ReadLineAsync();

        // ...followed by the small itemsGranted toast with the grant details.
        var itemsGrantedEventLine = await playerReader.ReadLineAsync();
        var itemsGrantedDataLine = await playerReader.ReadLineAsync();

        itemsGrantedEventLine.Should().Be("event: itemsGranted");
        itemsGrantedDataLine.Should().Contain("item-1");
        itemsGrantedDataLine.Should().Contain(characterEntity.Id.ToString());

        // and the character config itself was mutated through the revision store.
        var catchUpResponse = await playerClient.GetAsync(
            $"/PlayerCharacter/getplayercharacterconfig/{characterEntity.Id}?sinceRevision=1"
        );
        catchUpResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await catchUpResponse.Content.ReadAsStringAsync();
        body.Should().Contain("item-1");
    }

    [Fact]
    public async Task GrantItemsAsync_MergesWithExistingInventoryEntry_InsteadOfDuplicating()
    {
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        PlayerCharacterEntity characterEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            characterEntity = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Hero",
                PlayerUserId = player.Id.Value,
                CampagneId = campagne.Id.Value,
                RpgCharacterConfiguration = "{\"inventory\":[{\"itemUuid\":\"item-1\",\"amount\":2}]}",
                RpgCharacterConfigurationRevision = 1,
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
            await context.SaveChangesAsync();
        }

        var grantRequest = new GrantItemsRequestDto
        {
            Items = new List<GrantedItemDto> { new() { ItemUuid = "item-1", Amount = 3 } },
        };

        var response = await Client.PostAsJsonAsync($"/SessionCommand/grantitems/{characterEntity.Id}", grantRequest);
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        using var context2 = ContextFactory!.CreateDbContext();
        var reloaded = context2.PlayerCharacters.Single(c => c.Id == characterEntity.Id);
        reloaded.RpgCharacterConfiguration.Should().Contain("\"amount\":5");
        reloaded.RpgCharacterConfiguration.Should().NotContain("\"amount\":2");
    }

    [Fact]
    public async Task GrantItemsAsync_Returns401_WhenCallerIsNotDm()
    {
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        PlayerCharacterEntity characterEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            characterEntity = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CharacterName = "Hero",
                PlayerUserId = player.Id.Value,
                CampagneId = campagne.Id.Value,
                RpgCharacterConfiguration = "{\"inventory\":[]}",
                RpgCharacterConfigurationRevision = 1,
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        var grantRequest = new GrantItemsRequestDto
        {
            Items = new List<GrantedItemDto> { new() { ItemUuid = "item-1", Amount = 3 } },
        };

        // the player themselves (not the dm) tries to grant items to their own character.
        var response = await playerClient.PostAsJsonAsync($"/SessionCommand/grantitems/{characterEntity.Id}", grantRequest);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    private static async Task<StreamReader> OpenEventsStreamAsync(HttpClient client)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, "/events");
        var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead);
        response.EnsureSuccessStatusCode();
        var stream = await response.Content.ReadAsStreamAsync();
        var reader = new StreamReader(stream, Encoding.UTF8);

        // drain hello
        await reader.ReadLineAsync();
        await reader.ReadLineAsync();
        await reader.ReadLineAsync();

        return reader;
    }
}
