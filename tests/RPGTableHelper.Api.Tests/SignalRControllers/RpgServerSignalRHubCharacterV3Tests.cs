using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class RpgServerSignalRHubCharacterV3Tests : ControllerTestBase
{
    private static readonly TimeSpan HubCallbackTimeout = TimeSpan.FromSeconds(20);

    public RpgServerSignalRHubCharacterV3Tests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task SendUpdatedRpgCharacterConfigToDm_V3DmReceivesEnvelope_LegacyDmReceivesFullString()
    {
        var scenario = await SignalRHubTestSeed.SeedDmTwoPlayersCampagneAsync(ContextFactory!, Mapper!);
        var handle = Factory.Server.CreateHandler();

        var dmV3 = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var dmLegacy = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.DmUser));
        var player = CreateJsonHubConnection(handle, CreateJwtForUser(scenario.PlayerOneUser));

        var v3Received = new TaskCompletionSource<(string Env, string Pid, string Uid)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );
        var legacyReceived = new TaskCompletionSource<(string Cfg, string Pid, string Uid)>(
            TaskCreationOptions.RunContinuationsAsynchronously
        );

        dmV3.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSideV3",
            (env, pid, uid) => v3Received.TrySetResult((env, pid, uid))
        );
        dmLegacy.On<string, string, string>(
            "updateRpgCharacterConfigOnDmSide",
            (cfg, pid, uid) => legacyReceived.TrySetResult((cfg, pid, uid))
        );

        await dmV3.StartAsync();
        await dmLegacy.StartAsync();
        await player.StartAsync();

        await dmV3.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await dmLegacy.InvokeAsync(nameof(RpgServerSignalRHub.RegisterGame), scenario.CampagneId.ToString(), CancellationToken.None);
        await dmV3.InvokeAsync(nameof(RpgServerSignalRHub.RegisterClientProtocol), 3, CancellationToken.None);

        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.ReaddToSignalRGroups),
            "NULL",
            scenario.PlayerOneCharacterId.ToString(),
            CancellationToken.None
        );

        const string cfg = """{"hero":"Z","n":1}""";
        await player.InvokeAsync(
            nameof(RpgServerSignalRHub.SendUpdatedRpgCharacterConfigToDm),
            scenario.PlayerOneCharacterId.ToString(),
            cfg,
            CancellationToken.None
        );

        (await Task.WhenAny(v3Received.Task, Task.Delay(HubCallbackTimeout))).Should().Be(v3Received.Task);
        (await Task.WhenAny(legacyReceived.Task, Task.Delay(HubCallbackTimeout))).Should().Be(legacyReceived.Task);

        var v3 = await v3Received.Task;
        v3.Env.Should().Contain("full");
        v3.Env.Should().Contain("character");
        v3.Pid.Should().Be(scenario.PlayerOneCharacterId.ToString());
        v3.Uid.Should().Be(scenario.PlayerOneUser.Id.Value.ToString());

        var leg = await legacyReceived.Task;
        leg.Cfg.Should().Be(cfg);

        await using (var ctx = await ContextFactory!.CreateDbContextAsync())
        {
            var row = await ctx.PlayerCharacters.AsNoTracking().SingleAsync(c => c.Id == scenario.PlayerOneCharacterId);
            row.RpgCharacterConfiguration.Should().Be(cfg);
            row.RpgCharacterConfigurationRevision.Should().BeGreaterThan(0);
        }

        await dmV3.DisposeAsync();
        await dmLegacy.DisposeAsync();
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
