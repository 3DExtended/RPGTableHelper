using System.Net;
using System.Net.Http.Headers;
using System.Text;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class SessionControllerTests : ControllerTestBase
{
    public SessionControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task EnterAsync_WhenUserIsNotDmOrPlayerOfCampagne_ReturnsUnauthorized()
    {
        // arrange
        await ConfigureLoggedInUser();
        var otherUser = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory!,
            Mapper!,
            usernameOverride: "OtherDm"
        );
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, otherUser);

        // act
        var response = await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task EnterAsync_WhenUserIsDmOfCampagne_ReturnsOk()
    {
        // arrange
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, dm);

        // act
        var response = await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task EnterAsync_ByOneParticipant_BroadcastsParticipantOnline_ToOtherParticipantAlreadyInSession()
    {
        // arrange: player B is an already-accepted member and enters first, then DM (A) enters.
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

        var playerEnterResponse = await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null);
        playerEnterResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // act: DM enters the same session while the player is already present and listening.
        var dmEnterResponse = await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null);

        // assert
        dmEnterResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: participantOnline");
        dataLine.Should().Contain(dm.Id.Value.ToString());
        dataLine.Should().Contain(campagne.Id.Value.ToString());
    }

    [Fact]
    public async Task LeaveAsync_BroadcastsParticipantOffline_ToOtherParticipantInSession()
    {
        // arrange
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

        await playerClient.PostAsync($"/Session/enter/{campagne.Id.Value}", null);
        await Client.PostAsync($"/Session/enter/{campagne.Id.Value}", null);

        // drain the participantOnline event about the dm entering
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();
        await playerReader.ReadLineAsync();

        // act
        var leaveResponse = await Client.PostAsync($"/Session/leave/{campagne.Id.Value}", null);

        // assert
        leaveResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: participantOffline");
        dataLine.Should().Contain(dm.Id.Value.ToString());
        dataLine.Should().Contain(campagne.Id.Value.ToString());
    }
}
