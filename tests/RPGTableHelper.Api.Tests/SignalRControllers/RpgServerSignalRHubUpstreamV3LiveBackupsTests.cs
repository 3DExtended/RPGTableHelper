using System.Text.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.Api.Tests.TestData;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubUpstreamV3LiveBackupsTests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(60);

    public RpgServerSignalRHubUpstreamV3LiveBackupsTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgConfigColdV3_ProdColdSlicePatch_V1ReceivesMergedFull_V3ReceivesEnvelope()
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();

        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var liveJson = LiveBackupTestPaths.ReadAllText(LiveBackupTestPaths.CampaignRpgConfiguration);
        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(liveJson);

        var handle = Factory.Server.CreateHandler();
        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var legacyPlayer = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var v3Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var v1AnyFull = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        legacyPlayer.On<string>(
            "updateRpgConfig",
            json =>
            {
                if (json.Contains("\"allItems\"", StringComparison.Ordinal) && json.Contains("\"rpgName\"", StringComparison.Ordinal))
                {
                    v1AnyFull.TrySetResult(json);
                }
            }
        );

        var v3Cold = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        v3Player.On<string>("updateRpgConfigColdV3", env => v3Cold.TrySetResult(env));

        await dm.StartAsync();
        await legacyPlayer.StartAsync();
        await v3Player.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);
        await legacyPlayer.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await v3Player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );
        await v3Player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);

        // Baseline: store cold slice so we can build a patch later.
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold), scenario.CampagneId.ToString(), slices.ColdJson, CancellationToken.None);
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigHot), scenario.CampagneId.ToString(), slices.HotJson, CancellationToken.None);

        int fromRev;
        string? currentCold;
        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            fromRev = row.RpgConfigurationColdRevision;
            currentCold = row.RpgConfigurationCold;
        }

        // Change: remove one top-level key from cold to force a small patch.
        var coldNode = JsonNode.Parse(currentCold!) as JsonObject;
        coldNode.Should().NotBeNull();
        var firstKey = coldNode!.First().Key;
        var nextColdNode = (JsonObject)coldNode.DeepClone();
        nextColdNode.Remove(firstKey);
        var nextColdJson = nextColdNode.ToJsonString();

        var env = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope("cold", currentCold, nextColdJson, fromRev, fromRev + 1);

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigColdV3), scenario.CampagneId.ToString(), env, CancellationToken.None);

        (await Task.WhenAny(v3Cold.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v3Cold.Task);
        (await Task.WhenAny(v1AnyFull.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v1AnyFull.Task);

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfigurationColdRevision.Should().BeGreaterThan(fromRev);
        }

        await dm.DisposeAsync();
        await legacyPlayer.DisposeAsync();
        await v3Player.DisposeAsync();
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
