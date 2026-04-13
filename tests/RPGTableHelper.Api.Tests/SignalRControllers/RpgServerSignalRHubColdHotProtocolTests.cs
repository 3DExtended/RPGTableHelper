using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubColdHotProtocolTests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(20);
    private static readonly TimeSpan NegativeAssertionDelay = TimeSpan.FromMilliseconds(800);

    public RpgServerSignalRHubColdHotProtocolTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgConfigColdAndHot_MixedClients_V2GetsSlices_V1GetsLegacyFull()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();

        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var legacyPlayer = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser)); // protocol v1 (no handshake)
        var v2Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser)); // protocol v2 (handshake)

        var legacyFullReceived = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        legacyPlayer.On<string>(
            "updateRpgConfig",
            json =>
            {
                // Cold and hot updates can arrive as two legacy full broadcasts; only complete once merged.
                if (json.Contains("\"allItems\"") && json.Contains("\"rpgName\""))
                {
                    legacyFullReceived.TrySetResult(json);
                }
            }
        );

        var coldReceived = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var hotReceived = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        v2Player.On<string>("updateRpgConfigCold", json => coldReceived.TrySetResult(json));
        v2Player.On<string>("updateRpgConfigHot", json => hotReceived.TrySetResult(json));

        await dm.StartAsync();
        await legacyPlayer.StartAsync();
        await v2Player.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await legacyPlayer.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await v2Player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );

        // v2 handshake for player2 only
        await v2Player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 2, CancellationToken.None);

        const string cold = """{"allItems":[{"uuid":"i1"}]}""";
        const string hot = """{"rpgName":"MyGame"}""";

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold), scenario.CampagneId.ToString(), cold, CancellationToken.None);
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigHot), scenario.CampagneId.ToString(), hot, CancellationToken.None);

        // v2 client receives slices
        (await Task.WhenAny(coldReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(coldReceived.Task);
        (await Task.WhenAny(hotReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(hotReceived.Task);
        (await coldReceived.Task).Should().Be(cold);
        (await hotReceived.Task).Should().Be(hot);

        // legacy client receives merged full config (may require two broadcasts: after cold then after hot).
        (await Task.WhenAny(legacyFullReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(legacyFullReceived.Task);
        var full = await legacyFullReceived.Task;
        full.Should().Contain("\"allItems\"");
        full.Should().Contain("\"rpgName\"");

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfigurationCold.Should().Be(cold);
            row.RpgConfigurationHot.Should().Be(hot);
            row.RpgConfiguration.Should().Contain("\"allItems\"");
            row.RpgConfiguration.Should().Contain("\"rpgName\"");
        }

        await dm.DisposeAsync();
        await legacyPlayer.DisposeAsync();
        await v2Player.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfigCold_SamePayloadTwice_DoesNotBroadcastSecondTime()
    {
        var scenario = await SignalRHubTestSeed.SeedDmPlayerCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var p = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerUser));

        var coldCount = 0;
        p.On<string>("updateRpgConfigCold", _ => coldCount++);

        await dm.StartAsync();
        await p.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await p.InvokeAsync(nameof(RpgServerSignalRHub.ReaddToSignalRGroups), "NULL", scenario.PlayerCharacterId.ToString(), CancellationToken.None);
        await p.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 2, CancellationToken.None);

        const string cold = """{"allItems":[{"uuid":"i1"}]}""";
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold), scenario.CampagneId.ToString(), cold, CancellationToken.None);
        await Task.Delay(NegativeAssertionDelay);
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold), scenario.CampagneId.ToString(), cold, CancellationToken.None);

        await Task.Delay(NegativeAssertionDelay);
        coldCount.Should().Be(1);

        await dm.DisposeAsync();
        await p.DisposeAsync();
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
