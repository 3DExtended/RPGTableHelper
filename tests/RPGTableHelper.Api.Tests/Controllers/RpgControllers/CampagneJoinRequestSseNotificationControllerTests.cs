using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

/// <summary>
/// Coverage for sse-05: join-code + one-time DM approval keeps its REST flow, but membership-scoped SSE
/// notifies (not session-gated) tell the DM about new requests and the player about resolutions, whenever
/// their <c>/events</c> stream is up.
/// </summary>
public class CampagneJoinRequestSseNotificationControllerTests : ControllerTestBase
{
    public CampagneJoinRequestSseNotificationControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateNewCampagneJoinRequestAsync_NotifiesDm_WithJoinRequestCreatedEvent_WithoutSessionEnter()
    {
        // arrange: DM keeps their /events stream open but never calls SessionEnter.
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

        // act: player creates a join request via the join code (no SessionEnter involved anywhere).
        var createResponse = await playerClient.PostAsJsonAsync(
            "/CampagneJoinRequest/createcampagneJoinRequest",
            new CampagneJoinRequestCreateDto
            {
                CampagneJoinCode = campagne.JoinCode,
                PlayerCharacterId = characterEntity.Id.ToString(),
            }
        );
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var createdRequestId = await ReadIdentifierValueAsync(createResponse);

        // assert: DM is notified with the request identity + player display info, no session enter required.
        var eventLine = await dmReader.ReadLineAsync();
        var dataLine = await dmReader.ReadLineAsync();

        eventLine.Should().Be("event: joinRequestCreated");
        dataLine.Should().Contain(createdRequestId.ToString());
        dataLine.Should().Contain(characterEntity.Id.ToString());
        dataLine.Should().Contain(characterEntity.CharacterName);
        dataLine.Should().Contain(campagne.Id.Value.ToString());
    }

    [Fact]
    public async Task HandleCampagneJoinRequest_NotifiesPlayer_WithJoinRequestResolvedEvent_OnAccept_WithoutSessionEnter()
    {
        // arrange: player keeps their /events stream open but never calls SessionEnter.
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
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
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

        var createResponse = await playerClient.PostAsJsonAsync(
            "/CampagneJoinRequest/createcampagneJoinRequest",
            new CampagneJoinRequestCreateDto
            {
                CampagneJoinCode = campagne.JoinCode,
                PlayerCharacterId = characterEntity.Id.ToString(),
            }
        );
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var createdRequestId = await ReadIdentifierValueAsync(createResponse);

        // drain the joinRequestCreated event about the request the player itself just created (their own
        // events stream does not receive it - only the DM does - so nothing to drain here).

        // act: DM accepts the request.
        var handleResponse = await Client.PostAsJsonAsync(
            "/CampagneJoinRequest/handlejoinrequest",
            new HandleJoinRequestDto
            {
                CampagneJoinRequestId = createdRequestId.ToString(),
                Type = HandleJoinRequestType.Accept,
            }
        );
        handleResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert: player is notified their request was resolved, no session enter required.
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: joinRequestResolved");
        dataLine.Should().Contain(createdRequestId.ToString());
        dataLine.Should().Contain("Accept");
        dataLine.Should().Contain(campagne.Id.Value.ToString());
    }

    [Fact]
    public async Task HandleCampagneJoinRequest_NotifiesPlayer_WithJoinRequestResolvedEvent_OnDeny()
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
            };
            await context.PlayerCharacters.AddAsync(characterEntity);
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

        var createResponse = await playerClient.PostAsJsonAsync(
            "/CampagneJoinRequest/createcampagneJoinRequest",
            new CampagneJoinRequestCreateDto
            {
                CampagneJoinCode = campagne.JoinCode,
                PlayerCharacterId = characterEntity.Id.ToString(),
            }
        );
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var createdRequestId = await ReadIdentifierValueAsync(createResponse);

        // act
        var handleResponse = await Client.PostAsJsonAsync(
            "/CampagneJoinRequest/handlejoinrequest",
            new HandleJoinRequestDto
            {
                CampagneJoinRequestId = createdRequestId.ToString(),
                Type = HandleJoinRequestType.Deny,
            }
        );
        handleResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await playerReader.ReadLineAsync();
        var dataLine = await playerReader.ReadLineAsync();

        eventLine.Should().Be("event: joinRequestResolved");
        dataLine.Should().Contain(createdRequestId.ToString());
        dataLine.Should().Contain("Deny");
    }

    private static async Task<Guid> ReadIdentifierValueAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return Guid.Parse(document.RootElement.GetProperty("value").GetString()!);
    }
}
