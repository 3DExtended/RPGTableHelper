using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubUpstreamV3Tests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(20);

    public RpgServerSignalRHubUpstreamV3Tests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgConfigColdV3_Patch_UpdatesDb_AndBroadcastsV3()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();

        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var v3Player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerTwoUser));

        var v3Cold = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        v3Player.On<string>("updateRpgConfigColdV3", json => v3Cold.TrySetResult(json));

        await dm.StartAsync();
        await v3Player.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await v3Player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerTwoCharacterId.ToString(),
            CancellationToken.None
        );
        await v3Player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);

        const string baselineCold = """{"allItems":[]}""";
        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfigCold),
            scenario.CampagneId.ToString(),
            baselineCold,
            CancellationToken.None
        );

        int fromRev;
        string? currentCold;
        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            fromRev = row.RpgConfigurationColdRevision;
            currentCold = row.RpgConfigurationCold;
        }

        const string nextCold = """{"allItems":[{"uuid":"u1"}]}""";
        var envelope = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
            "cold",
            currentCold,
            nextCold,
            fromRev,
            fromRev + 1
        );

        await dm.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgConfigColdV3),
            scenario.CampagneId.ToString(),
            envelope,
            CancellationToken.None
        );

        (await Task.WhenAny(v3Cold.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v3Cold.Task);
        (await v3Cold.Task).Should().Contain("cold");

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.Campagnes.AsNoTracking().SingleAsync(c => c.Id == scenario.CampagneId);
            row.RpgConfigurationCold.Should().Contain("u1");
        }

        await dm.DisposeAsync();
        await v3Player.DisposeAsync();
    }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDmV3_Patch_ReachesDmV3()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();

        var dm = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var dmEnv = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);
        dm.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSideV3",
            (env, pid, _) =>
            {
                if (pid == scenario.PlayerOneCharacterId.ToString())
                {
                    dmEnv.TrySetResult(env);
                }
            }
        );

        await dm.StartAsync();
        await player.StartAsync();

        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );
        await dm.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);
        await player.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);

        const string baseline = """{"characterName":"P","uuid":"g1"}""";
        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            baseline,
            CancellationToken.None
        );

        int fromRev;
        string? currentCfg;
        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.PlayerCharacters.AsNoTracking().SingleAsync(p => p.Id == scenario.PlayerOneCharacterId);
            fromRev = row.RpgCharacterConfigurationRevision;
            currentCfg = row.RpgCharacterConfiguration;
        }

        const string nextCfg = """{"characterName":"P2","uuid":"g1"}""";
        var envelope = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
            "character",
            currentCfg,
            nextCfg,
            fromRev,
            fromRev + 1
        );

        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDmV3),
            scenario.PlayerOneCharacterId.ToString(),
            envelope,
            CancellationToken.None
        );

        (await Task.WhenAny(dmEnv.Task, Task.Delay(HubCallbackTimeout))).Should().Be(dmEnv.Task);
        (await dmEnv.Task).Should().Contain("character");

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
