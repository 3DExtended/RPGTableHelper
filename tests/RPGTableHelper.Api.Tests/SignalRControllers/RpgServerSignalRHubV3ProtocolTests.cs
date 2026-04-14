using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubV3ProtocolTests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(20);

    public RpgServerSignalRHubV3ProtocolTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgConfigColdAndHot_V3Player_GetsV3Envelopes_LegacyGetsFull()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();

        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var legacyPlayer = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));
        var v3Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var legacyFull = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        legacyPlayer.On<string>(
            "updateRpgConfig",
            json =>
            {
                if (json.Contains("\"allItems\"") && json.Contains("\"rpgName\""))
                {
                    legacyFull.TrySetResult(json);
                }
            }
        );

        var v3Cold = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        var v3Hot = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        v3Player.On<string>("updateRpgConfigColdV3", json => v3Cold.TrySetResult(json));
        v3Player.On<string>("updateRpgConfigHotV3", json => v3Hot.TrySetResult(json));

        await dm.StartAsync();
        await legacyPlayer.StartAsync();
        await v3Player.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
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

        const string cold = """{"allItems":[{"uuid":"i1"}]}""";
        const string hot = """{"rpgName":"HubV3"}""";

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold), scenario.CampagneId.ToString(), cold, CancellationToken.None);
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.SendUpdatedRpgConfigHot), scenario.CampagneId.ToString(), hot, CancellationToken.None);

        (await Task.WhenAny(v3Cold.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v3Cold.Task);
        (await Task.WhenAny(v3Hot.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v3Hot.Task);

        var coldEnv = await v3Cold.Task;
        coldEnv.Should().Contain("full");
        coldEnv.Should().Contain("cold");

        var hotEnv = await v3Hot.Task;
        hotEnv.Should().Contain("full");
        hotEnv.Should().Contain("hot");

        (await Task.WhenAny(legacyFull.Task, Task.Delay(HubCallbackTimeout))).Should().Be(legacyFull.Task);

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfigurationColdRevision.Should().BeGreaterThan(0);
            row.RpgConfigurationHotRevision.Should().BeGreaterThan(0);
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
