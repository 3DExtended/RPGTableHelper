using System.Collections.Concurrent;
using System.Diagnostics;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.WebApi;

[Authorize] // NOTE this does not work. I am using the IUserContext to ensure authorization!
public class RpgServerSignalRHub : Hub
{
    private sealed record ClientCaps(int protocolVersion);

    // In-memory capabilities registry; old clients never register => treated as protocol v1.
    private static readonly ConcurrentDictionary<string, ClientCaps> CapsByConnectionId = new();

    // Track group membership ourselves (SignalR doesn't expose group connection lists).
    private static readonly ConcurrentDictionary<string, ConcurrentDictionary<string, byte>> ConnectionIdsByGroupKey = new();
    private static readonly ConcurrentDictionary<string, ConcurrentDictionary<string, byte>> GroupKeysByConnectionId = new();

    private readonly ILogger _logger;
    private readonly IHostEnvironment _hostEnvironment;
    private readonly IQueryProcessor _queryProcessor;
    private readonly IUserContext _userContext;

    public RpgServerSignalRHub(
        IUserContext userContext,
        IQueryProcessor queryProcessor,
        ILogger logger,
        IHostEnvironment hostEnvironment
    )
    {
        // IMPORTANT NOTE: this is required as all methods in the signalr hub are authorized.
        // However, I wasnt able to configure SignalR to require an bearer token everywhere.
        // Hence, I am using the IUserContext to guard this Hub.
        _userContext = userContext;
        _queryProcessor = queryProcessor;
        _logger = logger;
        _hostEnvironment = hostEnvironment;
    }

    /// <summary>
    /// New clients call this once per connection to declare supported protocol features.
    /// Old clients simply won't call it and are treated as v1.
    /// </summary>
    public Task RegisterClientProtocol(int protocolVersion)
    {
        // Clamp to supported range (v1 legacy full, v2 cold/hot strings, v3 JSON Patch envelopes).
        var v = protocolVersion < 1 ? 1 : protocolVersion;
        if (v > 3)
        {
            v = 3;
        }

        CapsByConnectionId[Context.ConnectionId] = new ClientCaps(v);
        return Task.CompletedTask;
    }

    public async Task AskPlayersForRolls(string campagneId, string fightSequenceSerialized)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        await Clients
            .OthersInGroup(campagneId + "_All")
            .SendAsync("playersAreAskedForRolls", fightSequenceSerialized, (CancellationToken)default);
    }

    /// <summary>
    /// Test method for testing connections
    /// </summary>
    public Task Echo(string text)
    {
        return Clients.Caller.SendAsync("Echo", text, (CancellationToken)default);
    }

    /// <summary>
    /// Player Method to join a game
    /// </summary>
    public async Task JoinGame(string playercharacterid)
    {
        var playerCharacter = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(playercharacterid)),
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (
            playerCharacter.IsNone
            || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier
            || playerCharacter.Get().CampagneId == null
        )
        {
            return;
        }

        var campagneOfCharacter = await new CampagneQuery { ModelId = playerCharacter.Get().CampagneId! }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagneOfCharacter.IsNone)
        {
            return;
        }

        _logger.LogInformation(
            "A player with the name "
                + playerCharacter.Get().CharacterName
                + " would like to join the game with code "
                + campagneOfCharacter.Get().JoinCode
        );

        // ask DM for joining permissions:
        var allGroupKey = campagneOfCharacter.Get().Id.Value + "_All";
        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            allGroupKey,
            (CancellationToken)default
        );
        TrackAddToGroup(Context.ConnectionId, allGroupKey);
        await Clients.Caller.SendAsync("joinRequestAccepted", (CancellationToken)default);

        var campagneModel = campagneOfCharacter.Get();
        var pv = GetClientProtocolVersion();

        if (campagneModel.RpgConfiguration != null && pv < 2)
        {
            await Clients.Caller.SendAsync(
                "updateRpgConfig",
                campagneModel.RpgConfiguration,
                (CancellationToken)default
            );
        }

        var cold = campagneModel.RpgConfigurationCold;
        var hot = campagneModel.RpgConfigurationHot;
        if (string.IsNullOrWhiteSpace(cold) && string.IsNullOrWhiteSpace(hot) && campagneModel.RpgConfiguration != null)
        {
            var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(campagneModel.RpgConfiguration);
            cold = slices.ColdJson;
            hot = slices.HotJson;
        }

        var coldRev = campagneModel.RpgConfigurationColdRevision;
        var hotRev = campagneModel.RpgConfigurationHotRevision;

        // Protocol v2: full cold/hot strings.
        if (pv == 2)
        {
            if (!string.IsNullOrWhiteSpace(cold))
            {
                await Clients.Caller.SendAsync("updateRpgConfigCold", cold, (CancellationToken)default);
            }

            if (!string.IsNullOrWhiteSpace(hot))
            {
                await Clients.Caller.SendAsync("updateRpgConfigHot", hot, (CancellationToken)default);
            }
        }

        // Protocol v3: revisioned envelopes (full on join).
        if (pv >= 3)
        {
            if (!string.IsNullOrWhiteSpace(cold))
            {
                await Clients.Caller.SendAsync(
                    "updateRpgConfigColdV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("cold", coldRev, cold),
                    (CancellationToken)default
                );
            }

            if (!string.IsNullOrWhiteSpace(hot))
            {
                await Clients.Caller.SendAsync(
                    "updateRpgConfigHotV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("hot", hotRev, hot),
                    (CancellationToken)default
                );
            }

            var pcModel = playerCharacter.Get();
            var charJson = string.IsNullOrWhiteSpace(pcModel.RpgCharacterConfiguration)
                ? "{}"
                : pcModel.RpgCharacterConfiguration;
            var charRev = pcModel.RpgCharacterConfigurationRevision;
            await Clients.Caller.SendAsync(
                "updateMyRpgCharacterConfigV3",
                RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("character", charRev, charJson),
                pcModel.Id.Value.ToString(),
                (CancellationToken)default
            );
        }
    }

    public async Task SendPingToPlayers(string campagneId, string timestamp)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        await Clients.OthersInGroup(campagneId + "_All").SendAsync("pingFromDm", timestamp, (CancellationToken)default);
    }

    public async Task SendPongToDm(string campagneId, string timestamp)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        await Clients
            .Group(campagneId + "_Dms")
            .SendAsync(
                "pongFromPlayer",
                timestamp,
                _userContext.User.UserIdentifier.Value.ToString(),
                (CancellationToken)default
            );
    }

    public override async Task OnConnectedAsync()
    {
        // TODO update me for new flow
        // This newMessage call is what is not being received on the front end
        await Clients.All.SendAsync("aClientProvidedFunction", "ich bin ein test");

        // This console.WriteLine does print when I bring up the component in the front end.
        _logger.LogInformation("Context.ConnectionId:" + Context.ConnectionId); // This one is the only one filled...
        _logger.LogInformation("Context.User:" + _userContext.User!.ToString());
        _logger.LogInformation("Context.User.Identity.Name:" + _userContext.User!.UserIdentifier.Value);
        _logger.LogInformation("Context.UserIdentifier:" + Context.UserIdentifier);

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = _userContext.User.UserIdentifier.Value.ToString();
        if (exception != null)
        {
            _logger.LogWarning(
                exception,
                "SignalR OnDisconnectedAsync: ConnectionId={ConnectionId} UserId={UserId}",
                Context.ConnectionId,
                userId
            );
        }
        else
        {
            _logger.LogInformation(
                "SignalR OnDisconnectedAsync (no exception): ConnectionId={ConnectionId} UserId={UserId}",
                Context.ConnectionId,
                userId
            );
        }

        CapsByConnectionId.TryRemove(Context.ConnectionId, out _);
        TrackRemoveConnection(Context.ConnectionId);
        await Clients.Group("AllCampagnes_Dms").SendAsync("clientDisconnected", userId);

        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// This method can be called after a reconnect happend to add a client to their appropiate groups
    /// </summary>
    /// <param name="campagneId">The campagne the client wants to join</param>
    /// <param name="characterId">The playerid the client wants to use</param>
    public async Task ReaddToSignalRGroups(string? campagneId, string? characterId)
    {
        campagneId = campagneId == "NULL" ? null : campagneId;
        characterId = characterId == "NULL" ? null : characterId;

        if (campagneId == null && characterId == null)
        {
            _logger.LogInformation(
                "SignalR ReaddToSignalRGroups skipped (both null): ConnectionId={ConnectionId}",
                Context.ConnectionId
            );
            return;
        }

        Campagne.CampagneIdentifier? campagneIdParsed = null;
        bool isDm = false;

        if (campagneId != null)
        {
            var campagne = await new CampagneQuery
            {
                ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId!)),
            }
                .RunAsync(_queryProcessor, default)
                .ConfigureAwait(false);

            if (campagne.IsNone)
            {
                _logger.LogWarning(
                    "SignalR ReaddToSignalRGroups: campagne not found for CampagneId={CampagneId} ConnectionId={ConnectionId}",
                    campagneId,
                    Context.ConnectionId
                );
                return;
            }

            campagneIdParsed = campagne.Get().Id;
            isDm = campagne.Get().DmUserId == _userContext.User.UserIdentifier;
        }

        if (campagneIdParsed == null && characterId != null)
        {
            var playerCharacter = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(characterId!)),
            }
                .RunAsync(_queryProcessor, default)
                .ConfigureAwait(false);
            if (playerCharacter.IsNone)
            {
                _logger.LogWarning(
                    "SignalR ReaddToSignalRGroups: player character not found for CharacterId={CharacterId} ConnectionId={ConnectionId}",
                    characterId,
                    Context.ConnectionId
                );
                return;
            }

            campagneIdParsed = playerCharacter.Get().CampagneId;
            isDm = false;
        }

        if (campagneIdParsed != null)
        {
            var allGroupKey = campagneIdParsed.Value + "_All";
            await Groups.AddToGroupAsync(
                Context.ConnectionId,
                allGroupKey,
                (CancellationToken)default
            );
            TrackAddToGroup(Context.ConnectionId, allGroupKey);

            if (isDm)
            {
                var dmsGroupKey = campagneIdParsed.Value + "_Dms";
                await Groups.AddToGroupAsync(
                    Context.ConnectionId,
                    dmsGroupKey,
                    (CancellationToken)default
                );
                TrackAddToGroup(Context.ConnectionId, dmsGroupKey);

                await Groups.AddToGroupAsync(Context.ConnectionId, "AllCampagnes_Dms", (CancellationToken)default);
                TrackAddToGroup(Context.ConnectionId, "AllCampagnes_Dms");

                // in this case we want to request an update from each client...
                await Clients
                    .OthersInGroup(campagneIdParsed.Value + "_All")
                    .SendAsync("requestStatusFromPlayers", (CancellationToken)default);
            }

            // Confirms server→client delivery after groups are applied (helps validate the connection is not half-dead).
            await Clients.Caller.SendAsync(
                "signalRGroupsRejoined",
                campagneIdParsed.Value.ToString(),
                (CancellationToken)default
            );

            _logger.LogInformation(
                "SignalR ReaddToSignalRGroups succeeded: ConnectionId={ConnectionId} UserId={UserId} CampagneId={CampagneId} IsDm={IsDm}",
                Context.ConnectionId,
                _userContext.User.UserIdentifier.Value,
                campagneIdParsed.Value,
                isDm
            );
        }
    }

    /// <summary>
    /// DM Method for starting a session
    /// </summary>
    public async Task RegisterGame(string campagneId)
    {
        // ensure that user is dm for campagne
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        _logger.LogInformation("New game initiated for campagne: " + campagneId);

        await Groups.AddToGroupAsync(Context.ConnectionId, campagneId + "_All", (CancellationToken)default);
        TrackAddToGroup(Context.ConnectionId, campagneId + "_All");
        await Groups.AddToGroupAsync(Context.ConnectionId, campagneId + "_Dms", (CancellationToken)default);
        TrackAddToGroup(Context.ConnectionId, campagneId + "_Dms");
        await Groups.AddToGroupAsync(Context.ConnectionId, "AllCampagnes_Dms", (CancellationToken)default);
        TrackAddToGroup(Context.ConnectionId, "AllCampagnes_Dms");

        await Clients.Caller.SendAsync("registerGameResponse", campagne.Get().JoinCode, (CancellationToken)default);

        // in this case we want to request an update from each client...
        await Clients
            .OthersInGroup(campagneId + "_All")
            .SendAsync("requestStatusFromPlayers", (CancellationToken)default);
    }

    public async Task SendFightSequenceRollsToDm(string playercharacterid, string fightSequenceSerialized)
    {
        var playerCharacter = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(playercharacterid)),
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (
            playerCharacter.IsNone
            || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier
            || playerCharacter.Get().CampagneId == null
        )
        {
            return;
        }

        var campagneOfCharacter = await new CampagneQuery { ModelId = playerCharacter.Get().CampagneId! }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagneOfCharacter.IsNone)
        {
            return;
        }

        await Clients
            .OthersInGroup(campagneOfCharacter.Get().Id.Value + "_Dms")
            .SendAsync("dmReceivedFightSequenceAnswer", fightSequenceSerialized, (CancellationToken)default);
    }

    /// <summary>
    /// Grants a list of items to players.
    /// </summary>
    /// <param name="campagneId">the campagneId of the session</param>
    /// <param name="json">The json encoded grant for dart type "List of GrantedItemsForPlayer"</param>
    public async Task SendGrantedItemsToPlayers(string campagneId, string json)
    {
        // ensure that user is dm for campagne
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        // ask DM for joining permissions:
        await Clients
            .OthersInGroup(campagneId + "_All")
            .SendAsync("grantPlayerItems", json, (CancellationToken)default);
    }

    /// <summary>
    /// When a player updated their config (e.g. got an item, changed their HP etc.),
    /// this method sends this updated config to the dm.
    /// </summary>
    /// <param name="playercharacterid">the playercharacterid of the session</param>
    /// <param name="characterConfig">JSON string</param>
    public async Task SendUpdatedRpgCharacterConfigToDm(string playercharacterid, string characterConfig)
    {
        var playerCharacter = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(playercharacterid)),
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (
            playerCharacter.IsNone
            || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier
            || playerCharacter.Get().CampagneId == null
        )
        {
            return;
        }

        var campagneOfCharacter = await new CampagneQuery { ModelId = playerCharacter.Get().CampagneId! }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagneOfCharacter.IsNone)
        {
            return;
        }

        var updatedPlayerCharacter = playerCharacter.Get();

        // Server-side dedupe: skip DB + broadcast if nothing changed.
        if (updatedPlayerCharacter.RpgCharacterConfiguration == characterConfig)
        {
            return;
        }

        var oldCharacterConfig = updatedPlayerCharacter.RpgCharacterConfiguration;
        var fromCharacterRev = updatedPlayerCharacter.RpgCharacterConfigurationRevision;

        updatedPlayerCharacter.RpgCharacterConfiguration = characterConfig;
        updatedPlayerCharacter.RpgCharacterConfigurationRevision = fromCharacterRev + 1;
        var toCharacterRev = updatedPlayerCharacter.RpgCharacterConfigurationRevision;

        var updateResult = await new PlayerCharacterUpdateQuery { UpdatedModel = updatedPlayerCharacter }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);
        if (updateResult.IsNone)
        {
            return;
        }

        _logger.LogInformation("A player updated their character with name " + updatedPlayerCharacter.CharacterName);

        var dmsGroupKey = campagneOfCharacter.Get().Id.Value + "_Dms";
        var dmConnectionIds = GetTrackedConnectionsForGroup(dmsGroupKey).ToList();
        SplitBroadcastTargets(dmConnectionIds, out var v1Dm, out var v2Dm, out var v3Dm);
        var legacyDmIds = v1Dm.Concat(v2Dm).ToList();

        if (legacyDmIds.Count > 0)
        {
            await Clients
                .Clients(legacyDmIds)
                .SendAsync(
                    "updateRpgCharacterConfigOnDmSide",
                    characterConfig,
                    updatedPlayerCharacter.Id.Value.ToString(),
                    updatedPlayerCharacter.PlayerUserId.Value.ToString(),
                    (CancellationToken)default
                );
        }

        if (v3Dm.Count > 0)
        {
            var env = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                "character",
                oldCharacterConfig,
                characterConfig,
                fromCharacterRev,
                toCharacterRev
            );
            await Clients
                .Clients(v3Dm)
                .SendAsync(
                    "updateRpgCharacterConfigOnDmSideV3",
                    env,
                    updatedPlayerCharacter.Id.Value.ToString(),
                    updatedPlayerCharacter.PlayerUserId.Value.ToString(),
                    (CancellationToken)default
                );
        }

        // File backup only outside local/E2E test hosts (avoids /app/database and keeps tests deterministic).
        if (_hostEnvironment.IsEnvironment("E2ETest") || _hostEnvironment.IsEnvironment("LocalSignalRE2E"))
        {
            return;
        }

        string timestamp = DateTime.Now.ToString("yyyyMMdd-HHmm");
        string fileName =
            $"{updatedPlayerCharacter.CharacterName}-{updatedPlayerCharacter.Id.Value.ToString()}-{timestamp}-rpgbackup.json";

        string currentDirectory = "/app/database/"; // mounting point from docker compose

        if (Debugger.IsAttached)
        {
            currentDirectory = "./";
        }

        string fileBackupFolders = "configbackups";
        Directory.CreateDirectory(Path.Combine(currentDirectory, fileBackupFolders));

        string filePath = Path.Combine(currentDirectory, fileBackupFolders, fileName);
        try
        {
            await File.WriteAllTextAsync(filePath, characterConfig, (CancellationToken)default);
            _logger.LogInformation($"File saved to {filePath}");
        }
        catch (Exception ex)
        {
            _logger.LogInformation($"An error occurred: {ex.Message}");
        }
    }

    /// <summary>
    /// Player/DM: request latest RPG config snapshots (v2 strings or v3 envelopes) after a patch mismatch or reconnect.
    /// </summary>
    public async Task RequestRpgConfigSnapshot(string campagneId)
    {
        var campagneIdParsed = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId));
        var campagne = await new CampagneQuery { ModelId = campagneIdParsed }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone)
        {
            return;
        }

        var allowed = await new CampagneIsUserInCampagneQuery
        {
            CampagneId = campagneIdParsed,
            UserIdToCheck = _userContext.User.UserIdentifier,
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (allowed.IsNone || !allowed.Get())
        {
            return;
        }

        var m = campagne.Get();
        var cold = m.RpgConfigurationCold;
        var hot = m.RpgConfigurationHot;
        if (string.IsNullOrWhiteSpace(cold) && string.IsNullOrWhiteSpace(hot) && m.RpgConfiguration != null)
        {
            var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(m.RpgConfiguration);
            cold = slices.ColdJson;
            hot = slices.HotJson;
        }

        var pv = GetClientProtocolVersion();
        if (m.RpgConfiguration != null && pv < 2)
        {
            await Clients.Caller.SendAsync("updateRpgConfig", m.RpgConfiguration, (CancellationToken)default);
        }

        if (pv == 2)
        {
            if (!string.IsNullOrWhiteSpace(cold))
            {
                await Clients.Caller.SendAsync("updateRpgConfigCold", cold!, (CancellationToken)default);
            }

            if (!string.IsNullOrWhiteSpace(hot))
            {
                await Clients.Caller.SendAsync("updateRpgConfigHot", hot!, (CancellationToken)default);
            }
        }

        if (pv >= 3)
        {
            if (!string.IsNullOrWhiteSpace(cold))
            {
                await Clients.Caller.SendAsync(
                    "updateRpgConfigColdV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("cold", m.RpgConfigurationColdRevision, cold!),
                    (CancellationToken)default
                );
            }

            if (!string.IsNullOrWhiteSpace(hot))
            {
                await Clients.Caller.SendAsync(
                    "updateRpgConfigHotV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("hot", m.RpgConfigurationHotRevision, hot!),
                    (CancellationToken)default
                );
            }
        }
    }

    /// <summary>
    /// DM or owning player: request a full character config (legacy string or v3 envelope) after a patch mismatch.
    /// </summary>
    public async Task RequestPlayerCharacterConfigSnapshot(string playerCharacterId)
    {
        var pc = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(playerCharacterId)),
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (pc.IsNone || pc.Get().CampagneId == null)
        {
            return;
        }

        var campagne = await new CampagneQuery { ModelId = pc.Get().CampagneId! }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone)
        {
            return;
        }

        var m = pc.Get();
        var isDm = campagne.Get().DmUserId == _userContext.User.UserIdentifier;
        var isOwner = m.PlayerUserId == _userContext.User.UserIdentifier;
        if (!isDm && !isOwner)
        {
            return;
        }

        var json = string.IsNullOrWhiteSpace(m.RpgCharacterConfiguration) ? "{}" : m.RpgCharacterConfiguration;
        var rev = m.RpgCharacterConfigurationRevision;
        var pv = GetClientProtocolVersion();

        if (isDm)
        {
            if (pv >= 3)
            {
                await Clients.Caller.SendAsync(
                    "updateRpgCharacterConfigOnDmSideV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("character", rev, json),
                    m.Id.Value.ToString(),
                    m.PlayerUserId.Value.ToString(),
                    (CancellationToken)default
                );
            }
            else
            {
                await Clients.Caller.SendAsync(
                    "updateRpgCharacterConfigOnDmSide",
                    json,
                    m.Id.Value.ToString(),
                    m.PlayerUserId.Value.ToString(),
                    (CancellationToken)default
                );
            }
        }
        else if (isOwner)
        {
            if (pv >= 3)
            {
                await Clients.Caller.SendAsync(
                    "updateMyRpgCharacterConfigV3",
                    RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("character", rev, json),
                    m.Id.Value.ToString(),
                    (CancellationToken)default
                );
            }
            else
            {
                await Clients.Caller.SendAsync(
                    "updateMyRpgCharacterConfig",
                    json,
                    m.Id.Value.ToString(),
                    (CancellationToken)default
                );
            }
        }
    }

    /// <summary>
    /// Dm Method for updating all rpg configs
    /// </summary>
    public async Task SendUpdatedRpgConfig(string campagneId, string rpgConfig)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            // TODO how do i handle exceptions in signalr?
            return;
        }

        var updateCampagne = campagne.Get();
        var oldMerged = updateCampagne.RpgConfiguration;

        // Server-side dedupe: skip DB + broadcast if nothing changed.
        if (updateCampagne.RpgConfiguration == rpgConfig)
        {
            return;
        }

        var oldCold = updateCampagne.RpgConfigurationCold;
        var oldHot = updateCampagne.RpgConfigurationHot;
        var fromColdRev = updateCampagne.RpgConfigurationColdRevision;
        var fromHotRev = updateCampagne.RpgConfigurationHotRevision;

        updateCampagne.RpgConfiguration = rpgConfig;

        // Keep cold/hot columns in sync even for legacy clients.
        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(rpgConfig);
        var newCold = slices.ColdJson;
        var newHot = slices.HotJson;
        var coldChanged = !string.Equals(oldCold, newCold, StringComparison.Ordinal);
        var hotChanged = !string.Equals(oldHot, newHot, StringComparison.Ordinal);

        updateCampagne.RpgConfigurationCold = newCold;
        updateCampagne.RpgConfigurationHot = newHot;
        updateCampagne.RpgConfigurationSchemaVersion = slices.SchemaVersion;
        updateCampagne.RpgConfigurationColdRevision = coldChanged ? fromColdRev + 1 : fromColdRev;
        updateCampagne.RpgConfigurationHotRevision = hotChanged ? fromHotRev + 1 : fromHotRev;

        if (!string.Equals(oldMerged, updateCampagne.RpgConfiguration, StringComparison.Ordinal))
        {
            updateCampagne.RpgConfigurationMergedRevision++;
        }

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return;
        }

        var toColdRev = updateCampagne.RpgConfigurationColdRevision;
        var toHotRev = updateCampagne.RpgConfigurationHotRevision;

        // Broadcast legacy full config to protocol v1 clients.
        // IMPORTANT: exclude the sender connection to preserve legacy OthersInGroup semantics
        // (the DM should not receive their own update).
        var allConnectionIds = GetTrackedConnectionsForGroup(campagneId + "_All")
            .Where(id => id != Context.ConnectionId)
            .ToList();
        SplitBroadcastTargets(allConnectionIds, out var v1ConnectionIds, out var v2ConnectionIds, out var v3ConnectionIds);

        if (v1ConnectionIds.Count > 0)
        {
            await Clients.Clients(v1ConnectionIds).SendAsync("updateRpgConfig", rpgConfig, (CancellationToken)default);
        }

        if (v2ConnectionIds.Count > 0)
        {
            if (coldChanged)
            {
                await Clients.Clients(v2ConnectionIds).SendAsync("updateRpgConfigCold", newCold, (CancellationToken)default);
            }

            if (hotChanged)
            {
                await Clients.Clients(v2ConnectionIds).SendAsync("updateRpgConfigHot", newHot, (CancellationToken)default);
            }
        }

        if (v3ConnectionIds.Count > 0)
        {
            if (coldChanged)
            {
                var coldEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                    "cold",
                    oldCold,
                    newCold,
                    fromColdRev,
                    toColdRev
                );
                await Clients.Clients(v3ConnectionIds).SendAsync("updateRpgConfigColdV3", coldEnv, (CancellationToken)default);
            }

            if (hotChanged)
            {
                var hotEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                    "hot",
                    oldHot,
                    newHot,
                    fromHotRev,
                    toHotRev
                );
                await Clients.Clients(v3ConnectionIds).SendAsync("updateRpgConfigHotV3", hotEnv, (CancellationToken)default);
            }
        }

        // File backup only outside local/E2E test hosts (avoids /app/database and keeps tests deterministic).
        if (_hostEnvironment.IsEnvironment("E2ETest") || _hostEnvironment.IsEnvironment("LocalSignalRE2E"))
        {
            return;
        }

        string timestamp = DateTime.Now.ToString("yyyyMMdd");
        string fileName = $"{campagneId}-{timestamp}-rpgbackup.json";

        string currentDirectory = "/app/database/";
        if (Debugger.IsAttached)
        {
            currentDirectory = "./";
        }

        string fileBackupFolders = "configbackups";
        Directory.CreateDirectory(Path.Combine(currentDirectory, fileBackupFolders));

        string filePath = Path.Combine(currentDirectory, fileBackupFolders, fileName);
        try
        {
            // Write the long string to the file
            await File.WriteAllTextAsync(filePath, rpgConfig, (CancellationToken)default);
            _logger.LogInformation($"File saved to {filePath}");
        }
        catch (Exception ex)
        {
            _logger.LogInformation($"An error occurred: {ex.Message}");
        }
    }

    /// <summary>
    /// Protocol v2+ DM method: update cold slice only (big/rarely changing).
    /// Server recombines and also serves protocol v1 clients.
    /// </summary>
    public async Task SendUpdatedRpgConfigCold(string campagneId, string rpgConfigCold)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return;
        }

        var updateCampagne = campagne.Get();
        if (
            updateCampagne.RpgConfiguration != null
            && (updateCampagne.RpgConfigurationCold == null || updateCampagne.RpgConfigurationHot == null)
        )
        {
            var existingSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(updateCampagne.RpgConfiguration);
            updateCampagne.RpgConfigurationCold ??= existingSlices.ColdJson;
            updateCampagne.RpgConfigurationHot ??= existingSlices.HotJson;
            updateCampagne.RpgConfigurationSchemaVersion ??= existingSlices.SchemaVersion;
        }

        var oldMergedForCold = updateCampagne.RpgConfiguration;

        // Server-side dedupe: skip DB + broadcast if nothing changed.
        if (updateCampagne.RpgConfigurationCold == rpgConfigCold)
        {
            return;
        }

        var oldCold = updateCampagne.RpgConfigurationCold;
        var fromColdRev = updateCampagne.RpgConfigurationColdRevision;

        updateCampagne.RpgConfigurationCold = rpgConfigCold;
        updateCampagne.RpgConfigurationColdRevision = fromColdRev + 1;
        updateCampagne.RpgConfigurationSchemaVersion = RpgConfigColdHotSlicer.SchemaVersion;
        updateCampagne.RpgConfiguration = RpgConfigColdHotSlicer.MergeToLegacyFull(
            updateCampagne.RpgConfigurationCold,
            updateCampagne.RpgConfigurationHot
        );

        if (!string.Equals(oldMergedForCold, updateCampagne.RpgConfiguration, StringComparison.Ordinal))
        {
            updateCampagne.RpgConfigurationMergedRevision++;
        }

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return;
        }

        var toColdRev = updateCampagne.RpgConfigurationColdRevision;
        var allConnectionIds = GetTrackedConnectionsForGroup(campagneId + "_All").ToList();
        SplitBroadcastTargets(allConnectionIds, out var v1ConnectionIds, out var v2ConnectionIds, out var v3ConnectionIds);

        if (v2ConnectionIds.Count > 0)
        {
            await Clients.Clients(v2ConnectionIds).SendAsync("updateRpgConfigCold", rpgConfigCold, (CancellationToken)default);
        }

        if (v3ConnectionIds.Count > 0)
        {
            var coldEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                "cold",
                oldCold,
                rpgConfigCold,
                fromColdRev,
                toColdRev
            );
            await Clients.Clients(v3ConnectionIds).SendAsync("updateRpgConfigColdV3", coldEnv, (CancellationToken)default);
        }

        if (v1ConnectionIds.Count > 0)
        {
            await Clients.Clients(v1ConnectionIds)
                .SendAsync("updateRpgConfig", updateCampagne.RpgConfiguration, (CancellationToken)default);
        }
    }

    /// <summary>
    /// Protocol v2+ DM method: update hot slice only (small/frequently changing).
    /// Server recombines and also serves protocol v1 clients.
    /// </summary>
    public async Task SendUpdatedRpgConfigHot(string campagneId, string rpgConfigHot)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return;
        }

        var updateCampagne = campagne.Get();
        if (
            updateCampagne.RpgConfiguration != null
            && (updateCampagne.RpgConfigurationCold == null || updateCampagne.RpgConfigurationHot == null)
        )
        {
            var existingSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(updateCampagne.RpgConfiguration);
            updateCampagne.RpgConfigurationCold ??= existingSlices.ColdJson;
            updateCampagne.RpgConfigurationHot ??= existingSlices.HotJson;
            updateCampagne.RpgConfigurationSchemaVersion ??= existingSlices.SchemaVersion;
        }

        var oldMergedForHot = updateCampagne.RpgConfiguration;

        // Server-side dedupe: skip DB + broadcast if nothing changed.
        if (updateCampagne.RpgConfigurationHot == rpgConfigHot)
        {
            return;
        }

        var oldHot = updateCampagne.RpgConfigurationHot;
        var fromHotRev = updateCampagne.RpgConfigurationHotRevision;

        updateCampagne.RpgConfigurationHot = rpgConfigHot;
        updateCampagne.RpgConfigurationHotRevision = fromHotRev + 1;
        updateCampagne.RpgConfigurationSchemaVersion = RpgConfigColdHotSlicer.SchemaVersion;
        updateCampagne.RpgConfiguration = RpgConfigColdHotSlicer.MergeToLegacyFull(
            updateCampagne.RpgConfigurationCold,
            updateCampagne.RpgConfigurationHot
        );

        if (!string.Equals(oldMergedForHot, updateCampagne.RpgConfiguration, StringComparison.Ordinal))
        {
            updateCampagne.RpgConfigurationMergedRevision++;
        }

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return;
        }

        var toHotRev = updateCampagne.RpgConfigurationHotRevision;
        var allConnectionIds = GetTrackedConnectionsForGroup(campagneId + "_All").ToList();
        SplitBroadcastTargets(allConnectionIds, out var v1ConnectionIds, out var v2ConnectionIds, out var v3ConnectionIds);

        if (v2ConnectionIds.Count > 0)
        {
            await Clients.Clients(v2ConnectionIds).SendAsync("updateRpgConfigHot", rpgConfigHot, (CancellationToken)default);
        }

        if (v3ConnectionIds.Count > 0)
        {
            var hotEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                "hot",
                oldHot,
                rpgConfigHot,
                fromHotRev,
                toHotRev
            );
            await Clients.Clients(v3ConnectionIds).SendAsync("updateRpgConfigHotV3", hotEnv, (CancellationToken)default);
        }

        if (v1ConnectionIds.Count > 0)
        {
            await Clients.Clients(v1ConnectionIds)
                .SendAsync("updateRpgConfig", updateCampagne.RpgConfiguration, (CancellationToken)default);
        }
    }

    /// <summary>
    /// Protocol v3: DM sends the cold slice as a v3 envelope (RFC 6902 patch or full) to reduce upstream bandwidth.
    /// </summary>
    public async Task SendUpdatedRpgConfigColdV3(string campagneId, string envelopeJson)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return;
        }

        var updateCampagne = campagne.Get();
        if (
            updateCampagne.RpgConfiguration != null
            && (updateCampagne.RpgConfigurationCold == null || updateCampagne.RpgConfigurationHot == null)
        )
        {
            var existingSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(updateCampagne.RpgConfiguration);
            updateCampagne.RpgConfigurationCold ??= existingSlices.ColdJson;
            updateCampagne.RpgConfigurationHot ??= existingSlices.HotJson;
            updateCampagne.RpgConfigurationSchemaVersion ??= existingSlices.SchemaVersion;
        }

        if (
            !RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
                envelopeJson,
                "cold",
                updateCampagne.RpgConfigurationCold,
                updateCampagne.RpgConfigurationColdRevision,
                out var coldJson,
                out _
            )
        )
        {
            return;
        }

        await SendUpdatedRpgConfigCold(campagneId, coldJson).ConfigureAwait(false);
    }

    /// <summary>
    /// Protocol v3: DM sends the hot slice as a v3 envelope (RFC 6902 patch or full) to reduce upstream bandwidth.
    /// </summary>
    public async Task SendUpdatedRpgConfigHotV3(string campagneId, string envelopeJson)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return;
        }

        var updateCampagne = campagne.Get();
        if (
            updateCampagne.RpgConfiguration != null
            && (updateCampagne.RpgConfigurationCold == null || updateCampagne.RpgConfigurationHot == null)
        )
        {
            var existingSlices = RpgConfigColdHotSlicer.SliceFromLegacyFull(updateCampagne.RpgConfiguration);
            updateCampagne.RpgConfigurationCold ??= existingSlices.ColdJson;
            updateCampagne.RpgConfigurationHot ??= existingSlices.HotJson;
            updateCampagne.RpgConfigurationSchemaVersion ??= existingSlices.SchemaVersion;
        }

        if (
            !RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
                envelopeJson,
                "hot",
                updateCampagne.RpgConfigurationHot,
                updateCampagne.RpgConfigurationHotRevision,
                out var hotJson,
                out _
            )
        )
        {
            return;
        }

        await SendUpdatedRpgConfigHot(campagneId, hotJson).ConfigureAwait(false);
    }

    /// <summary>
    /// Protocol v3: DM sends merged RPG configuration as a v3 envelope (patch or full) to reduce upstream bandwidth.
    /// </summary>
    public async Task SendUpdatedRpgConfigV3(string campagneId, string envelopeJson)
    {
        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneId)) }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return;
        }

        var updateCampagne = campagne.Get();
        if (
            !RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
                envelopeJson,
                "merged",
                updateCampagne.RpgConfiguration,
                updateCampagne.RpgConfigurationMergedRevision,
                out var rpgConfig,
                out _
            )
        )
        {
            return;
        }

        await SendUpdatedRpgConfig(campagneId, rpgConfig).ConfigureAwait(false);
    }

    /// <summary>
    /// Protocol v3: player sends character configuration as a v3 envelope (patch or full) to reduce upstream bandwidth.
    /// </summary>
    public async Task SendUpdatedRpgCharacterConfigToDmV3(string playercharacterid, string envelopeJson)
    {
        var playerCharacter = await new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Parse(playercharacterid)),
        }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (
            playerCharacter.IsNone
            || playerCharacter.Get().PlayerUserId != _userContext.User.UserIdentifier
            || playerCharacter.Get().CampagneId == null
        )
        {
            return;
        }

        var m = playerCharacter.Get();
        if (
            !RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
                envelopeJson,
                "character",
                m.RpgCharacterConfiguration,
                m.RpgCharacterConfigurationRevision,
                out var characterConfig,
                out _
            )
        )
        {
            return;
        }

        await SendUpdatedRpgCharacterConfigToDm(playercharacterid, characterConfig).ConfigureAwait(false);
    }

    private static void SplitBroadcastTargets(
        IReadOnlyList<string> connectionIds,
        out List<string> v1ConnectionIds,
        out List<string> v2ConnectionIds,
        out List<string> v3ConnectionIds
    )
    {
        v1ConnectionIds = new List<string>();
        v2ConnectionIds = new List<string>();
        v3ConnectionIds = new List<string>();
        foreach (var id in connectionIds)
        {
            if (!CapsByConnectionId.TryGetValue(id, out var caps))
            {
                v1ConnectionIds.Add(id);
                continue;
            }

            if (caps.protocolVersion >= 3)
            {
                v3ConnectionIds.Add(id);
            }
            else if (caps.protocolVersion == 2)
            {
                v2ConnectionIds.Add(id);
            }
            else
            {
                v1ConnectionIds.Add(id);
            }
        }
    }

    private static void TrackAddToGroup(string connectionId, string groupKey)
    {
        var set = ConnectionIdsByGroupKey.GetOrAdd(groupKey, _ => new ConcurrentDictionary<string, byte>());
        set[connectionId] = 0;

        var groups = GroupKeysByConnectionId.GetOrAdd(connectionId, _ => new ConcurrentDictionary<string, byte>());
        groups[groupKey] = 0;
    }

    private static IReadOnlyList<string> GetTrackedConnectionsForGroup(string groupKey)
    {
        return ConnectionIdsByGroupKey.TryGetValue(groupKey, out var set) ? set.Keys.ToList() : Array.Empty<string>();
    }

    private static void TrackRemoveConnection(string connectionId)
    {
        if (!GroupKeysByConnectionId.TryRemove(connectionId, out var groups))
        {
            return;
        }

        foreach (var groupKey in groups.Keys)
        {
            if (ConnectionIdsByGroupKey.TryGetValue(groupKey, out var set))
            {
                set.TryRemove(connectionId, out _);
                if (set.IsEmpty)
                {
                    ConnectionIdsByGroupKey.TryRemove(groupKey, out _);
                }
            }
        }
    }

    private int GetClientProtocolVersion()
    {
        return CapsByConnectionId.TryGetValue(Context.ConnectionId, out var caps) ? caps.protocolVersion : 1;
    }
}
