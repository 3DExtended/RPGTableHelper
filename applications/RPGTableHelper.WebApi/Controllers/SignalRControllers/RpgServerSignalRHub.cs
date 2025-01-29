using System.Security.Cryptography;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;

namespace RPGTableHelper.WebApi;

[Authorize] // NOTE this does not work. I am using the IUserContext to ensure authorization!
public class RpgServerSignalRHub : Hub
{
    private readonly ILogger _logger;
    private readonly IQueryProcessor _queryProcessor;
    private readonly IUserContext _userContext;

    public RpgServerSignalRHub(IUserContext userContext, IQueryProcessor queryProcessor, ILogger logger)
    {
        // IMPORTANT NOTE: this is required as all methods in the signalr hub are authorized.
        // However, I wasnt able to configure SignalR to require an bearer token everywhere.
        // Hence, I am using the IUserContext to guard this Hub.
        _userContext = userContext;
        _queryProcessor = queryProcessor;
        _logger = logger;
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

        _logger.LogInformation("A player with the name "
                + playerCharacter.Get().CharacterName
                + " would like to join the game with code "
                + campagneOfCharacter.Get().JoinCode);

        // ask DM for joining permissions:
        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            campagneOfCharacter.Get().Id.Value + "_All",
            (CancellationToken)default
        );
        await Clients.Caller.SendAsync("joinRequestAccepted", (CancellationToken)default);

        if (campagneOfCharacter.Get().RpgConfiguration != null)
        {
            await Clients.Caller.SendAsync(
                "updateRpgConfig",
                campagneOfCharacter.Get().RpgConfiguration,
                (CancellationToken)default
            );
        }
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
        await Clients
            .Group("AllCampagnes_Dms")
            .SendAsync("clientDisconnected", _userContext.User.UserIdentifier.Value.ToString());

        _logger.LogInformation("Disconnected: Context.Username:" + Context.UserIdentifier); // This one is the only one filled...

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
                return;
            }

            campagneIdParsed = playerCharacter.Get().CampagneId;
            isDm = false;
        }

        if (campagneIdParsed != null)
        {
            await Groups.AddToGroupAsync(
                Context.ConnectionId,
                campagneIdParsed.Value + "_All",
                (CancellationToken)default
            );

            if (isDm)
            {
                await Groups.AddToGroupAsync(
                    Context.ConnectionId,
                    campagneIdParsed.Value + "_Dms",
                    (CancellationToken)default
                );

                await Groups.AddToGroupAsync(Context.ConnectionId, "AllCampagnes_Dms", (CancellationToken)default);

                // in this case we want to request an update from each client...
                await Clients
                    .OthersInGroup(campagneIdParsed.Value + "_All")
                    .SendAsync("requestStatusFromPlayers", (CancellationToken)default);
            }
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
        await Groups.AddToGroupAsync(Context.ConnectionId, campagneId + "_Dms", (CancellationToken)default);
        await Groups.AddToGroupAsync(Context.ConnectionId, "AllCampagnes_Dms", (CancellationToken)default);

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
        updatedPlayerCharacter.RpgCharacterConfiguration = characterConfig;
        var updateResult = await new PlayerCharacterUpdateQuery { UpdatedModel = updatedPlayerCharacter }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);
        if (updateResult.IsNone)
        {
            return;
        }

        _logger.LogInformation("A player updated their character with name " + updatedPlayerCharacter.CharacterName);

        string timestamp = DateTime.Now.ToString("yyyyMMdd-HHmm");
        string fileName =
            $"{updatedPlayerCharacter.CharacterName}-{updatedPlayerCharacter.Id.Value.ToString()}-{timestamp}-rpgbackup.json";

        string currentDirectory = Directory.GetCurrentDirectory();
        string fileBackupFolders = "configbackups";
        Directory.CreateDirectory(Path.Combine(currentDirectory, fileBackupFolders));

        string filePath = Path.Combine(currentDirectory, fileBackupFolders, fileName);
        try
        {
            // Write the long string to the file
            await File.WriteAllTextAsync(filePath, characterConfig, (CancellationToken)default);
            _logger.LogInformation($"File saved to {filePath}");
        }
        catch (Exception ex)
        {
            _logger.LogInformation($"An error occurred: {ex.Message}");
        }

        // ask DM for joining permissions:
        await Clients
            .Group(campagneOfCharacter.Get().Id.Value + "_Dms")
            .SendAsync(
                "updateRpgCharacterConfigOnDmSide",
                characterConfig,
                updatedPlayerCharacter.Id.Value.ToString(),
                updatedPlayerCharacter.PlayerUserId.Value.ToString(),
                (CancellationToken)default
            );
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
        updateCampagne.RpgConfiguration = rpgConfig;

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, default)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return;
        }

        await Clients
            .OthersInGroup(campagneId + "_All")
            .SendAsync("updateRpgConfig", rpgConfig, (CancellationToken)default);

        string timestamp = DateTime.Now.ToString("yyyyMMdd");
        string fileName = $"{campagneId}-{timestamp}-rpgbackup.json";

        string currentDirectory = Directory.GetCurrentDirectory();
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
}
