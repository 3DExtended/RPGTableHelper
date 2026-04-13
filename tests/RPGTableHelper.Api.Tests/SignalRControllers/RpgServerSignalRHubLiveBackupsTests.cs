using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.Api.Tests.TestData;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

/// <summary>
/// SignalR hub tests using real production campaign JSON from <see cref="LiveBackupTestPaths.CampaignRpgConfiguration" />.
/// Validates v1 (full <c>updateRpgConfig</c>) vs v2 (<c>updateRpgConfigCold</c> + <c>updateRpgConfigHot</c>) paths.
/// </summary>
public class RpgServerSignalRHubLiveBackupsTests : ControllerTestBase
{
    /// <summary>Large prod JSON + SignalR; allow headroom over default 20s.</summary>
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(60);

    public RpgServerSignalRHubLiveBackupsTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgConfig_ProdCampaignJson_V1ReceivesFull_V2ReceivesSlices()
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();

        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var liveJson = LiveBackupTestPaths.ReadAllText(LiveBackupTestPaths.CampaignRpgConfiguration);
        var expectedSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(liveJson);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var legacyPlayer = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var v2Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var v1Full = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        legacyPlayer.On<string>(
            "updateRpgConfig",
            json =>
            {
                if (LiveBackupTestPaths.JsonDeepEquals(json, liveJson))
                {
                    v1Full.TrySetResult(json);
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
        await v2Player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 2, CancellationToken.None);

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfig),
            scenario.CampagneId.ToString(),
            liveJson,
            CancellationToken.None
        );

        (await Task.WhenAny(v1Full.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v1Full.Task);
        (await Task.WhenAny(coldReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(coldReceived.Task);
        (await Task.WhenAny(hotReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(hotReceived.Task);

        LiveBackupTestPaths.JsonDeepEquals(await v1Full.Task, liveJson).Should().BeTrue();
        (await coldReceived.Task).Should().Be(expectedSlices.ColdJson);
        (await hotReceived.Task).Should().Be(expectedSlices.HotJson);

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            LiveBackupTestPaths.JsonDeepEquals(row.RpgConfiguration!, liveJson).Should().BeTrue();
            row.RpgConfigurationCold.Should().Be(expectedSlices.ColdJson);
            row.RpgConfigurationHot.Should().Be(expectedSlices.HotJson);
            row.RpgConfigurationSchemaVersion.Should().Be(RpgConfigColdHotSlicer.SchemaVersion);
        }

        await dm.DisposeAsync();
        await legacyPlayer.DisposeAsync();
        await v2Player.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgConfigColdThenHot_ProdSlices_V1ReceivesMergedFull_V2ReceivesEachSlice()
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();

        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var liveJson = LiveBackupTestPaths.ReadAllText(LiveBackupTestPaths.CampaignRpgConfiguration);
        var expectedSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(liveJson);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var legacyPlayer = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var v2Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var v1MergedFull = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        legacyPlayer.On<string>(
            "updateRpgConfig",
            json =>
            {
                if (json.Contains("\"allItems\"", StringComparison.Ordinal)
                    && json.Contains("\"rpgName\"", StringComparison.Ordinal))
                {
                    v1MergedFull.TrySetResult(json);
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
        await v2Player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 2, CancellationToken.None);

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold),
            scenario.CampagneId.ToString(),
            expectedSlices.ColdJson,
            CancellationToken.None
        );

        (await Task.WhenAny(coldReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(coldReceived.Task);
        (await coldReceived.Task).Should().Be(expectedSlices.ColdJson);

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfigHot),
            scenario.CampagneId.ToString(),
            expectedSlices.HotJson,
            CancellationToken.None
        );

        (await Task.WhenAny(hotReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(hotReceived.Task);
        (await Task.WhenAny(v1MergedFull.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v1MergedFull.Task);

        (await hotReceived.Task).Should().Be(expectedSlices.HotJson);
        LiveBackupTestPaths.JsonDeepEquals(await v1MergedFull.Task, liveJson).Should().BeTrue();

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            LiveBackupTestPaths.JsonDeepEquals(row.RpgConfiguration!, liveJson).Should().BeTrue();
        }

        await dm.DisposeAsync();
        await legacyPlayer.DisposeAsync();
        await v2Player.DisposeAsync();
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
