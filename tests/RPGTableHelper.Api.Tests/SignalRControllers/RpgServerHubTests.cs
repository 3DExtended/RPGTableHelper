using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.SignalR.Client;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.Shared.Tests.Controllers.Authorization;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubTests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(15);

    public RpgServerSignalRHubTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task Echo_ShouldReturnSentString()
    {
        Dictionary<string, object>? challengeDict = await RegisterControllerTests.GenerateAndReceiveEncryptionChallenge(
            QueryProcessor,
            Client,
            Context!
        );

        string? jwtResult = await RegisterControllerTests.LoginAndReceiveJWT(QueryProcessor, Client, challengeDict);

        await RegisterControllerTests.VerifyLoginValidity(Client, jwtResult);

        var handle = Factory.Server.CreateHandler();
        var connection = CreateJsonHubConnection(handle, jwtResult!);

        var received = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        connection.On<string>(
            "Echo",
            message => received.TrySetResult(message)
        );
        await connection.StartAsync();
        var message = "Ich komme aus dem Test";

        await connection.InvokeAsync(nameof(RpgServerSignalRHub.Echo), message, CancellationToken.None);

        var completed = await Task.WhenAny(received.Task, Task.Delay(HubCallbackTimeout));
        completed.Should().Be(received.Task);
        (await received.Task).Should().Be(message);

        await connection.DisposeAsync();
    }

    [Fact]
    public async Task Echo_ShouldFailIfUnauthorized()
    {
        var handle = Factory.Server.CreateHandler();
        var connection = CreateJsonHubConnection(handle, "asdfasdf");

        string? resultFromServer = null;
        connection.On<string>(
            "Echo",
            m => resultFromServer = m
        );

        var task1 = () => connection.StartAsync();
        await task1.Should().ThrowAsync<HttpRequestException>();

        var message = "Ich komme aus dem Test";

        var task = () => connection.InvokeAsync(nameof(RpgServerSignalRHub.Echo), message, CancellationToken.None);
        await task.Should().ThrowAsync<InvalidOperationException>();

        resultFromServer.Should().BeNull();
        await connection.DisposeAsync();
    }

    [Fact]
    public async Task SendPingToPlayers_AfterRegisterGame_PlayerReceivesTimestamp()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var playerJwt = CreateJwtForUser(scenario.PlayerUser);

        var handle = Factory.Server.CreateHandler();
        var dmConnection = CreateJsonHubConnection(handle, dmJwt);
        var playerConnection = CreateJsonHubConnection(handle, playerJwt);

        var pingReceived = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        playerConnection.On<string>(
            "pingFromDm",
            ts => pingReceived.TrySetResult(ts)
        );

        await dmConnection.StartAsync();
        await playerConnection.StartAsync();

        await dmConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );

        await playerConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        const string ts = "ping-ts-1";
        await dmConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPingToPlayers),
            scenario.CampagneId.ToString(),
            ts,
            CancellationToken.None
        );

        (await Task.WhenAny(pingReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(pingReceived.Task);
        (await pingReceived.Task).Should().Be(ts);

        await dmConnection.DisposeAsync();
        await playerConnection.DisposeAsync();
    }

    [Fact]
    public async Task SendPongToDm_AfterRegisterGame_DmReceivesPongWithUserId()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var playerJwt = CreateJwtForUser(scenario.PlayerUser);

        var handle = Factory.Server.CreateHandler();
        var dmConnection = CreateJsonHubConnection(handle, dmJwt);
        var playerConnection = CreateJsonHubConnection(handle, playerJwt);

        var pongReceived = new TaskCompletionSource<(string Ts, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        dmConnection.On<string, string>(
            "pongFromPlayer",
            (timestamp, userId) => pongReceived.TrySetResult((timestamp, userId))
        );

        await dmConnection.StartAsync();
        await playerConnection.StartAsync();

        await dmConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );

        await playerConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        const string ts = "pong-ts-1";
        await playerConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPongToDm),
            scenario.CampagneId.ToString(),
            ts,
            CancellationToken.None
        );

        (await Task.WhenAny(pongReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(pongReceived.Task);
        var result = await pongReceived.Task;
        result.Ts.Should().Be(ts);
        result.UserId.Should().Be(scenario.PlayerUser.Id.Value.ToString());
        await dmConnection.DisposeAsync();
        await playerConnection.DisposeAsync();
    }

    [Fact]
    public async Task AfterPlayerReconnects_ReaddToSignalRGroups_PingStillReceived()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var playerJwt = CreateJwtForUser(scenario.PlayerUser);

        var handle = Factory.Server.CreateHandler();
        var dmConnection = CreateJsonHubConnection(handle, dmJwt);
        var playerConnection = CreateJsonHubConnection(handle, playerJwt);

        var pingReceived = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        playerConnection.On<string>("pingFromDm", ts => pingReceived.TrySetResult(ts));

        await dmConnection.StartAsync();
        await playerConnection.StartAsync();

        await dmConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );

        await playerConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        await playerConnection.StopAsync();

        await playerConnection.StartAsync();
        await playerConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        const string ts = "ping-after-reconnect";
        await dmConnection.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPingToPlayers),
            scenario.CampagneId.ToString(),
            ts,
            CancellationToken.None
        );

        (await Task.WhenAny(pingReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(pingReceived.Task);
        (await pingReceived.Task).Should().Be(ts);

        await dmConnection.DisposeAsync();
        await playerConnection.DisposeAsync();
    }

    [Fact]
    public async Task SendPingToPlayers_TwoClients_BothReceiveSameTimestamp()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var jwtOne = CreateJwtForUser(scenario.PlayerOneUser);
        var jwtTwo = CreateJwtForUser(scenario.PlayerTwoUser);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, dmJwt);
        var playerOne = CreateJsonHubConnection(handle, jwtOne);
        var playerTwo = CreateJsonHubConnection(handle, jwtTwo);

        var pingOne = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var pingTwo = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        playerOne.On<string>("pingFromDm", ts => pingOne.TrySetResult(ts));
        playerTwo.On<string>("pingFromDm", ts => pingTwo.TrySetResult(ts));

        await dm.StartAsync();
        await playerOne.StartAsync();
        await playerTwo.StartAsync();

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );

        await playerOne.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await playerTwo.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        const string ts = "ping-broadcast-2p";
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPingToPlayers),
            scenario.CampagneId.ToString(),
            ts,
            CancellationToken.None
        );

        var allPings = Task.WhenAll(pingOne.Task, pingTwo.Task);
        (await Task.WhenAny(allPings, Task.Delay(HubCallbackTimeout))).Should().Be(allPings);
        (await pingOne.Task).Should().Be(ts);
        (await pingTwo.Task).Should().Be(ts);

        await dm.DisposeAsync();
        await playerOne.DisposeAsync();
        await playerTwo.DisposeAsync();
    }

    [Fact]
    public async Task SendPongToDm_TwoClients_DmReceivesBothUserIds()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var jwtOne = CreateJwtForUser(scenario.PlayerOneUser);
        var jwtTwo = CreateJwtForUser(scenario.PlayerTwoUser);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, dmJwt);
        var playerOne = CreateJsonHubConnection(handle, jwtOne);
        var playerTwo = CreateJsonHubConnection(handle, jwtTwo);

        var idOne = scenario.PlayerOneUser.Id.Value.ToString();
        var idTwo = scenario.PlayerTwoUser.Id.Value.ToString();

        var pongFromOne = new TaskCompletionSource<(string Ts, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        var pongFromTwo = new TaskCompletionSource<(string Ts, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );

        dm.On<string, string>(
            "pongFromPlayer",
            (timestamp, userId) =>
            {
                if (userId == idOne)
                {
                    pongFromOne.TrySetResult((timestamp, userId));
                }

                if (userId == idTwo)
                {
                    pongFromTwo.TrySetResult((timestamp, userId));
                }
            }
        );

        await dm.StartAsync();
        await playerOne.StartAsync();
        await playerTwo.StartAsync();

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );

        await playerOne.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await playerTwo.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        const string tsOne = "pong-from-a";
        const string tsTwo = "pong-from-b";
        await playerOne.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPongToDm),
            scenario.CampagneId.ToString(),
            tsOne,
            CancellationToken.None
        );
        await playerTwo.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPongToDm),
            scenario.CampagneId.ToString(),
            tsTwo,
            CancellationToken.None
        );

        var both = Task.WhenAll(pongFromOne.Task, pongFromTwo.Task);
        (await Task.WhenAny(both, Task.Delay(HubCallbackTimeout))).Should().Be(both);

        var r1 = await pongFromOne.Task;
        var r2 = await pongFromTwo.Task;
        r1.Ts.Should().Be(tsOne);
        r1.UserId.Should().Be(idOne);
        r2.Ts.Should().Be(tsTwo);
        r2.UserId.Should().Be(idTwo);

        await dm.DisposeAsync();
        await playerOne.DisposeAsync();
        await playerTwo.DisposeAsync();
    }

    private static HubConnection CreateJsonHubConnection(HttpMessageHandler handle, string? jwt) =>
        new HubConnectionBuilder()
            .WithUrl(
                "wss://localhost/Chat",
                options =>
                {
                    options.HttpMessageHandlerFactory = _ => handle;
                    options.AccessTokenProvider = () => Task.FromResult(jwt);
                }
            )
            .Build();
}
