using System.Collections.Concurrent;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

/// <summary>
/// Hub contract tests for campagne vs character JSON payloads (sizes, auth, persistence)
/// ahead of splitting DTOs and SignalR message shapes.
/// </summary>
public class RpgServerSignalRHubPayloadAndEdgeTests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(20);
    private static readonly TimeSpan LargePayloadTimeout = TimeSpan.FromSeconds(45);
    private static readonly TimeSpan NegativeAssertionDelay = TimeSpan.FromMilliseconds(800);

    public RpgServerSignalRHubPayloadAndEdgeTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    public static TheoryData<int> RpgConfigApproxSizes =>
        new() { 8, 256, 4_096, 48_000 };

    public static TheoryData<int> CharacterConfigApproxSizes =>
        new() { 8, 512, 12_000 };

    [Theory]
    [MemberData(nameof(RpgConfigApproxSizes))]
    public async Task SendUpdatedRpgConfig_TwoPlayers_ReceiveExactPayload(int minChars)
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var payload = SignalRTestPayloadBuilder.JsonObjectWithMinimumLength(minChars);
        payload.Length.Should().BeGreaterThanOrEqualTo(minChars);

        var handle = Factory.Server.CreateHandler();
        var dmJwt = CreateJwtForUser(scenario.DmUser);
        var jwtOne = CreateJwtForUser(scenario.PlayerOneUser);
        var jwtTwo = CreateJwtForUser(scenario.PlayerTwoUser);

        var dm = CreateJsonHubConnection(handle, dmJwt);
        var playerOne = CreateJsonHubConnection(handle, jwtOne);
        var playerTwo = CreateJsonHubConnection(handle, jwtTwo);

        var receivedOne = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var receivedTwo = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        playerOne.On<string>("updateRpgConfig", json => receivedOne.TrySetResult(json));
        playerTwo.On<string>("updateRpgConfig", json => receivedTwo.TrySetResult(json));

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

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            payload,
            CancellationToken.None
        );

        var timeout = minChars >= 20_000 ? LargePayloadTimeout : HubCallbackTimeout;
        var both = Task.WhenAll(receivedOne.Task, receivedTwo.Task);
        (await Task.WhenAny(both, Task.Delay(timeout))).Should().Be(both);

        (await receivedOne.Task).Should().Be(payload);
        (await receivedTwo.Task).Should().Be(payload);

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfiguration.Should().Be(payload);
        }

        await dm.DisposeAsync();
        await playerOne.DisposeAsync();
        await playerTwo.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_EmptyString_PlayersReceiveEmptyString()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var r1 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var r2 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        p1.On<string>("updateRpgConfig", s => r1.TrySetResult(s));
        p2.On<string>("updateRpgConfig", s => r2.TrySetResult(s));

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            string.Empty,
            CancellationToken.None
        );

        (await Task.WhenAll(r1.Task, r2.Task).WaitAsync(HubCallbackTimeout)).Should().AllSatisfy(s => s.Should().BeEmpty());

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfiguration.Should().BeEmpty();
        }

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_UnicodePayload_TwoPlayersReceiveExact()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var payload = SignalRTestPayloadBuilder.JsonWithUnicodeEscapes();

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var r1 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var r2 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        p1.On<string>("updateRpgConfig", s => r1.TrySetResult(s));
        p2.On<string>("updateRpgConfig", s => r2.TrySetResult(s));

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            payload,
            CancellationToken.None
        );

        (await Task.WhenAll(r1.Task, r2.Task).WaitAsync(HubCallbackTimeout)).Should().AllSatisfy(s => s.Should().Be(payload));

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_PlayerInvoke_DoesNotBroadcastToPeers()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var fired = false;
        p1.On<string>("updateRpgConfig", _ => fired = true);
        p2.On<string>("updateRpgConfig", _ => fired = true);

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            """{"from":"player"}""",
            CancellationToken.None
        );

        await Task.Delay(NegativeAssertionDelay);
        fired.Should().BeFalse();

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_UnknownCampagneId_DoesNotBroadcast()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var fired = false;
        p1.On<string>("updateRpgConfig", _ => fired = true);

        await dm.StartAsync();
        await p1.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            Guid.NewGuid().ToString(),
            "{}",
            CancellationToken.None
        );

        await Task.Delay(NegativeAssertionDelay);
        fired.Should().BeFalse();

        await dm.DisposeAsync();
        await p1.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_BackToBackUpdates_BothPlayersReceiveLatestEachTime()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var first = """{"v":1}""";
        var second = SignalRTestPayloadBuilder.JsonObjectWithMinimumLength(2_000);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var bag = new ConcurrentBag<string>();
        void OnConfig(string json) => bag.Add(json);
        p1.On<string>("updateRpgConfig", OnConfig);
        p2.On<string>("updateRpgConfig", OnConfig);

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            first,
            CancellationToken.None
        );
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            second,
            CancellationToken.None
        );

        await Task.Delay(500);
        bag.Should().HaveCount(4);
        bag.Should().Contain(first);
        bag.Should().Contain(second);

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDm_EmptyString_DmReceivesAndPersists()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var received = new TaskCompletionSource<(string Cfg, string CharId, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (cfg, charId, userId) => received.TrySetResult((cfg, charId, userId))
        );

        await dm.StartAsync();
        await p1.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );

        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            string.Empty,
            CancellationToken.None
        );

        (await Task.WhenAny(received.Task, Task.Delay(HubCallbackTimeout))).Should().Be(received.Task);
        var r = await received.Task;
        r.Cfg.Should().BeEmpty();
        r.CharId.Should().Be(scenario.PlayerOneCharacterId.ToString());

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.PlayerCharacters.AsNoTracking().SingleAsync(c => c.Id == scenario.PlayerOneCharacterId);
            row.RpgCharacterConfiguration.Should().BeEmpty();
        }

        await dm.DisposeAsync();
        await p1.DisposeAsync();
    }

    [Theory]
    [MemberData(nameof(CharacterConfigApproxSizes))]
    public async Task SendUpdatedRpgCharacterConfigToDm_DmReceivesConfigCharacterIdAndUserId(int minChars)
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var payload = SignalRTestPayloadBuilder.JsonObjectWithMinimumLength(minChars);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var playerOne = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var received = new TaskCompletionSource<(string Cfg, string CharId, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (cfg, charId, userId) => received.TrySetResult((cfg, charId, userId))
        );

        await dm.StartAsync();
        await playerOne.StartAsync();

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

        await playerOne.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            payload,
            CancellationToken.None
        );

        var timeout = minChars >= 8_000 ? LargePayloadTimeout : HubCallbackTimeout;
        (await Task.WhenAny(received.Task, Task.Delay(timeout))).Should().Be(received.Task);

        var result = await received.Task;
        result.Cfg.Should().Be(payload);
        result.CharId.Should().Be(scenario.PlayerOneCharacterId.ToString());
        result.UserId.Should().Be(scenario.PlayerOneUser.Id.Value.ToString());

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.PlayerCharacters.AsNoTracking().SingleAsync(c => c.Id == scenario.PlayerOneCharacterId);
            row.RpgCharacterConfiguration.Should().Be(payload);
        }

        await dm.DisposeAsync();
        await playerOne.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDm_TwoPlayersSequential_DmReceivesBothDistinctPayloads()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var cfgA = """{"hero":"A","slots":[1,2,3]}""";
        var cfgB = SignalRTestPayloadBuilder.JsonObjectWithMinimumLength(3_500);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var bag = new ConcurrentBag<(string Cfg, string CharId, string UserId)>();
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (cfg, charId, userId) => bag.Add((cfg, charId, userId))
        );

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            cfgA,
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerTwoCharacterId.ToString(),
            cfgB,
            CancellationToken.None
        );

        await Task.Delay(600);
        bag.Should().HaveCount(2);
        bag.Should().Contain(t => t.CharId == scenario.PlayerOneCharacterId.ToString() && t.Cfg == cfgA);
        bag.Should().Contain(t => t.CharId == scenario.PlayerTwoCharacterId.ToString() && t.Cfg == cfgB);

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDm_PlayerCannotUpdateAnotherUsersCharacter_DmReceivesNothing()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var fired = false;
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (_, _, _) => fired = true
        );

        await dm.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            """{"nope":true}""",
            CancellationToken.None
        );

        await Task.Delay(NegativeAssertionDelay);
        fired.Should().BeFalse();

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var one = await ctx.PlayerCharacters.AsNoTracking().SingleAsync(c => c.Id == scenario.PlayerOneCharacterId);
            one.RpgCharacterConfiguration.Should().Be("{}");
        }

        await dm.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDm_UnknownCharacterId_DmReceivesNothing()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var fired = false;
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (_, _, _) => fired = true
        );

        await dm.StartAsync();
        await p1.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );

        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            Guid.NewGuid().ToString(),
            "{}",
            CancellationToken.None
        );

        await Task.Delay(NegativeAssertionDelay);
        fired.Should().BeFalse();

        await dm.DisposeAsync();
        await p1.DisposeAsync();
    }

    [Fact]
    public async Task SendPingToPlayers_EmptyTimestamp_PlayerReceivesEmptyString()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerUser));

        var ping = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        player.On<string>("pingFromDm", s => ping.TrySetResult(s));

        await dm.StartAsync();
        await player.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPingToPlayers),
            scenario.CampagneId.ToString(),
            string.Empty,
            CancellationToken.None
        );

        (await Task.WhenAny(ping.Task, Task.Delay(HubCallbackTimeout))).Should().Be(ping.Task);
        (await ping.Task).Should().BeEmpty();

        await dm.DisposeAsync();
        await player.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfig_DmOwnConnection_DoesNotReceiveUpdateRpgConfig()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p1 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var p2 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var dmGotConfig = false;
        dm.On<string>("updateRpgConfig", _ => dmGotConfig = true);
        var r1 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var r2 = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        p1.On<string>("updateRpgConfig", s => r1.TrySetResult(s));
        p2.On<string>("updateRpgConfig", s => r2.TrySetResult(s));

        await dm.StartAsync();
        await p1.StartAsync();
        await p2.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await p1.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await p2.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        const string payload = """{"dmEcho":false}""";
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            payload,
            CancellationToken.None
        );

        (await Task.WhenAll(r1.Task, r2.Task).WaitAsync(HubCallbackTimeout)).Should().AllSatisfy(s => s.Should().Be(payload));
        await Task.Delay(NegativeAssertionDelay);
        dmGotConfig.Should().BeFalse();

        await dm.DisposeAsync();
        await p1.DisposeAsync();
        await p2.DisposeAsync();
    }

    [Fact]
    public async Task SendPongToDm_EmptyTimestamp_DmReceivesEmptyString()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerUser));

        var pong = new TaskCompletionSource<(string Ts, string UserId)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        dm.On<string, string>(
            "pongFromPlayer",
            (ts, userId) => pong.TrySetResult((ts, userId))
        );

        await dm.StartAsync();
        await player.StartAsync();
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.RegisterGame),
            scenario.CampagneId.ToString(),
            CancellationToken.None
        );
        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerCharacterId.ToString(),
            CancellationToken.None
        );

        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.SendPongToDm),
            scenario.CampagneId.ToString(),
            string.Empty,
            CancellationToken.None
        );

        (await Task.WhenAny(pong.Task, Task.Delay(HubCallbackTimeout))).Should().Be(pong.Task);
        var r = await pong.Task;
        r.Ts.Should().BeEmpty();
        r.UserId.Should().Be(scenario.PlayerUser.Id.Value.ToString());

        await dm.DisposeAsync();
        await player.DisposeAsync();
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
