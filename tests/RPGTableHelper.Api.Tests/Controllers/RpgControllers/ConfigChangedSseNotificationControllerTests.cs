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
/// Multi-client coverage for sse-04: after a successful config PATCH/PUT, session participants receive a
/// session-scoped <c>campagneConfigChanged</c> / <c>characterConfigChanged</c> SSE notify carrying only
/// <c>{ id, revision }</c> (no config body), and only users with an active <c>SessionEnter</c> for that
/// campagne are notified.
/// </summary>
public class ConfigChangedSseNotificationControllerTests : ControllerTestBase
{
    public ConfigChangedSseNotificationControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task PatchCampagneRpgConfigAsync_NotifiesOtherSessionParticipant_WithIdAndRevisionOnly()
    {
        // arrange: DM (writer) and an accepted player both enter the table session.
        var dm = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "SSE01",
            DmUserId = dm.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(
                new PlayerCharacterEntity
                {
                    Id = Guid.NewGuid(),
                    CharacterName = "Hero",
                    PlayerUserId = player.Id.Value,
                    CampagneId = entity.Id,
                }
            );
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var playerEventsRequest = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var playerEventsResponse = await playerClient.SendAsync(
            playerEventsRequest,
            HttpCompletionOption.ResponseHeadersRead
        );
        playerEventsResponse.EnsureSuccessStatusCode();
        await using var playerStream = await playerEventsResponse.Content.ReadAsStreamAsync();
        using var playerReader = new StreamReader(playerStream, Encoding.UTF8);

        // drain hello
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        (await playerClient.PostAsync($"/Session/enter/{entity.Id}", null)).StatusCode.Should().Be(HttpStatusCode.OK);
        (await Client.PostAsync($"/Session/enter/{entity.Id}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        // drain the participantOnline event about the dm entering
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"new\"}]",
        };

        // act: writer (DM) PATCHes the campagne config.
        var patchResponse = await Client.PatchAsJsonAsync($"/Campagne/patchcampagneconfig/{entity.Id}", patchRequest);
        patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var patchResult = await patchResponse.Content.ReadFromJsonAsync<ConfigWriteResultDto>();

        // assert: peer is notified with id + revision only, then catches up over REST.
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: campagneConfigChanged");
        dataLine.Should().Contain(entity.Id.ToString());
        dataLine.Should().Contain(patchResult!.Revision.ToString());
        dataLine.Should().NotContain("rpgName");

        var catchUpResponse = await playerClient.GetAsync($"/Campagne/getcampagneconfig/{entity.Id}?sinceRevision=1");
        catchUpResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var catchUp = await catchUpResponse.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        catchUp!.Revision.Should().Be(patchResult.Revision);
    }

    [Fact]
    public async Task PutCampagneRpgConfigAsync_NotifiesOtherSessionParticipant_WithIdAndRevisionOnly()
    {
        // arrange
        var dm = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "SSE02",
            DmUserId = dm.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(
                new PlayerCharacterEntity
                {
                    Id = Guid.NewGuid(),
                    CharacterName = "Hero",
                    PlayerUserId = player.Id.Value,
                    CampagneId = entity.Id,
                }
            );
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var playerEventsRequest = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var playerEventsResponse = await playerClient.SendAsync(
            playerEventsRequest,
            HttpCompletionOption.ResponseHeadersRead
        );
        playerEventsResponse.EnsureSuccessStatusCode();
        await using var playerStream = await playerEventsResponse.Content.ReadAsStreamAsync();
        using var playerReader = new StreamReader(playerStream, Encoding.UTF8);

        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        await playerClient.PostAsync($"/Session/enter/{entity.Id}", null);
        await Client.PostAsync($"/Session/enter/{entity.Id}", null);

        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        // act
        var putResponse = await Client.PutAsJsonAsync(
            $"/Campagne/updatecampagneconfig/{entity.Id}",
            new CampagneUpdateRpgConfigDto { RpgConfiguration = "{\"rpgName\":\"new\"}", FromRevision = 1 }
        );
        putResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var putResult = await putResponse.Content.ReadFromJsonAsync<ConfigWriteResultDto>();

        // assert
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: campagneConfigChanged");
        dataLine.Should().Contain(entity.Id.ToString());
        dataLine.Should().Contain(putResult!.Revision.ToString());
        dataLine.Should().NotContain("rpgName");
    }

    [Fact]
    public async Task PatchCampagneRpgConfigAsync_DoesNotNotify_PlayerWhoHasNotEnteredSession()
    {
        // arrange: player is an accepted member but never called SessionEnter.
        var dm = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "SSE03",
            DmUserId = dm.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var player = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Player1");
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(
                new PlayerCharacterEntity
                {
                    Id = Guid.NewGuid(),
                    CharacterName = "Hero",
                    PlayerUserId = player.Id.Value,
                    CampagneId = entity.Id,
                }
            );
            await context.SaveChangesAsync();
        }

        using var playerClient = Factory.CreateClient();
        playerClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(player)
        );

        using var playerEventsRequest = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var playerEventsResponse = await playerClient.SendAsync(
            playerEventsRequest,
            HttpCompletionOption.ResponseHeadersRead
        );
        playerEventsResponse.EnsureSuccessStatusCode();
        await using var playerStream = await playerEventsResponse.Content.ReadAsStreamAsync();
        using var playerReader = new StreamReader(playerStream, Encoding.UTF8);

        // drain hello only; player never enters the session.
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        await Client.PostAsync($"/Session/enter/{entity.Id}", null);

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"new\"}]",
        };

        // act
        var patchResponse = await Client.PatchAsJsonAsync($"/Campagne/patchcampagneconfig/{entity.Id}", patchRequest);
        patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert: nothing else is written to the player's stream beyond the drained hello; a race-free way to
        // check this is to read with a short timeout and confirm no line arrives.
        var readTask = playerReader.ReadLineAsync();
        var completed = await Task.WhenAny(readTask, Task.Delay(TimeSpan.FromMilliseconds(300)));
        completed.Should().NotBe(readTask);
    }

    [Fact]
    public async Task PatchPlayerCharacterRpgConfigAsync_NotifiesDmInSession_WithIdAndRevisionOnly()
    {
        // arrange: DM and character-owning player both enter the table session; player writes their config.
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
                RpgCharacterConfiguration = "{\"hp\":10}",
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

        using var dmEventsRequest = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var dmEventsResponse = await Client.SendAsync(dmEventsRequest, HttpCompletionOption.ResponseHeadersRead);
        dmEventsResponse.EnsureSuccessStatusCode();
        await using var dmStream = await dmEventsResponse.Content.ReadAsStreamAsync();
        using var dmReader = new StreamReader(dmStream, Encoding.UTF8);

        // drain hello
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();

        (await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);
        (await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null)).StatusCode.Should().Be(HttpStatusCode.OK);

        // drain the participantOnline event about the player entering
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/hp\",\"value\":5}]",
        };

        // act: player (writer) PATCHes their own character config.
        var patchResponse = await playerClient.PatchAsJsonAsync(
            $"/PlayerCharacter/patchcharacterconfig/{characterEntity.Id}",
            patchRequest
        );
        patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var patchResult = await patchResponse.Content.ReadFromJsonAsync<ConfigWriteResultDto>();

        // assert: DM is notified with id + revision only.
        var eventLine = await dmReader.ReadLineAsync();
        var dataLine = await dmReader.ReadLineAsync();

        eventLine.Should().Be("event: characterConfigChanged");
        dataLine.Should().Contain(characterEntity.Id.ToString());
        dataLine.Should().Contain(patchResult!.Revision.ToString());
        dataLine.Should().NotContain("hp");
    }

    [Fact]
    public async Task PutPlayerCharacterRpgConfigAsync_NotifiesDmInSession_WithIdAndRevisionOnly()
    {
        // arrange
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
                RpgCharacterConfiguration = "{\"hp\":10}",
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

        using var dmEventsRequest = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var dmEventsResponse = await Client.SendAsync(dmEventsRequest, HttpCompletionOption.ResponseHeadersRead);
        dmEventsResponse.EnsureSuccessStatusCode();
        await using var dmStream = await dmEventsResponse.Content.ReadAsStreamAsync();
        using var dmReader = new StreamReader(dmStream, Encoding.UTF8);

        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();

        await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null);
        await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null);

        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();
        await dmReader.ReadLineAsync();

        // act
        var putResponse = await playerClient.PutAsJsonAsync(
            $"/PlayerCharacter/updatecharacterconfig/{characterEntity.Id}",
            new PlayerCharacterUpdateRpgConfigDto { RpgCharacterConfiguration = "{\"hp\":5}", FromRevision = 1 }
        );
        putResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var putResult = await putResponse.Content.ReadFromJsonAsync<ConfigWriteResultDto>();

        // assert
        var eventLine = await dmReader.ReadLineAsync();
        var dataLine = await dmReader.ReadLineAsync();

        eventLine.Should().Be("event: characterConfigChanged");
        dataLine.Should().Contain(characterEntity.Id.ToString());
        dataLine.Should().Contain(putResult!.Revision.ToString());
        dataLine.Should().NotContain("hp");
    }
}
