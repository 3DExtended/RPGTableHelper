using System.Security.Cryptography;
using Microsoft.AspNetCore.SignalR;

namespace RPGTableHelper.WebApi;

public class RpgServerHub : Hub
{
    /// <summary>
    /// DM Method for starting a session
    /// </summary>
    public async Task RegisterGame(string campagneName)
    {
        Console.WriteLine("New game initiated for campagne: " + campagneName);
        var gameToken = GenerateRefreshToken();

        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            gameToken + "_All",
            (CancellationToken)default
        );

        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            gameToken + "_Dms",
            (CancellationToken)default
        );

        await Clients.Caller.SendAsync(
            "registerGameResponse",
            gameToken,
            (CancellationToken)default
        );
    }

    /// <summary>
    /// Player Method to join a game
    /// </summary>
    public async Task JoinGame(string playerName, string gameCode)
    {
        Console.WriteLine(
            "A player with the name "
                + playerName
                + " would like to join the game with code "
                + gameCode
        );

        // ask DM for joining permissions:
        await Clients
            .Group(gameCode + "_Dms")
            .SendAsync(
                "requestJoinPermission",
                playerName,
                gameCode,
                Context.ConnectionId,
                (CancellationToken)default
            );
    }

    /// <summary>
    /// When a player updated their config (e.g. got an item, changed their HP etc.),
    /// this method sends this updated config to the dm.
    /// </summary>
    /// <param name="gameCode">the game code of the session</param>
    /// <param name="characterConfig">JSON string</param>
    public async Task SendUpdatedRpgCharacterConfigToDm(string gameCode, string characterConfig)
    {
        Console.WriteLine("A player updated their character for code " + gameCode);

        // ask DM for joining permissions:
        await Clients
            .Group(gameCode + "_Dms")
            .SendAsync(
                "updateRpgCharacterConfigOnDmSide",
                characterConfig,
                (CancellationToken)default
            );
    }

    /// <summary>
    /// Grants a list of items to players.
    /// </summary>
    /// <param name="gameCode">the game code of the session</param>
    /// <param name="json">The json encoded grant for dart type "List<GrantedItemsForPlayer>"</param>
    public async Task SendGrantedItemsToPlayers(string gameCode, string json)
    {
        Console.WriteLine("A dm granted items to their players for code " + gameCode);

        // ask DM for joining permissions:
        await Clients
            .Group(gameCode + "_All")
            .SendAsync("grantPlayerItems", json, (CancellationToken)default);
    }

    /// <summary>
    /// Dm Method to accept a join request
    /// </summary>
    public async Task AcceptJoinRequest(
        string playerName,
        string gameCode,
        string connectionId,
        string rpgConfig
    )
    {
        Console.WriteLine($"A player named {playerName} was accepted to game {gameCode}");

        // ask DM for joining permissions:
        await Groups.AddToGroupAsync(connectionId, gameCode + "_All", (CancellationToken)default);
        await Clients
            .Client(connectionId)
            .SendAsync("joinRequestAccepted", (CancellationToken)default);

        await Clients
            .Group(gameCode + "_All")
            .SendAsync("updateRpgConfig", rpgConfig, (CancellationToken)default);
    }

    /// <summary>
    /// Dm Method for updating all rpg configs
    /// </summary>
    public async Task SendUpdatedRpgConfig(string gameCode, string rpgConfig)
    {
        Console.WriteLine($"The DM sent an updated RPG config for game {gameCode}");

        await Clients
            .OthersInGroup(gameCode + "_All")
            .SendAsync("updateRpgConfig", rpgConfig, (CancellationToken)default);

        string timestamp = DateTime.Now.ToString("yyyyMMdd");
        string fileName = $"{timestamp}-rpgbackup.json";
        string currentDirectory = Directory.GetCurrentDirectory();
        string filePath = Path.Combine(currentDirectory, fileName);
        try
        {
            // Write the long string to the file
            await File.WriteAllTextAsync(filePath, rpgConfig, (CancellationToken)default);
            Console.WriteLine($"File saved to {filePath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }
    }

    public override async Task OnConnectedAsync()
    {
        // This newMessage call is what is not being received on the front end
        await Clients.All.SendAsync("aClientProvidedFunction", "ich bin ein test");

        // This console.WriteLine does print when I bring up the component in the front end.
        Console.WriteLine("Context.ConnectionId:" + Context.ConnectionId); // This one is the only one filled...
        Console.WriteLine("Context.User:" + Context.User.ToString());
        Console.WriteLine("Context.User.Identity.Name:" + Context.User.Identity.Name);
        Console.WriteLine("Context.UserIdentifier:" + Context.UserIdentifier);

        await base.OnConnectedAsync();
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        Console.WriteLine("Disconnected: Context.ConnectionId:" + Context.ConnectionId); // This one is the only one filled...

        return base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Generates a random string with pattern 000-000
    /// </summary>
    /// <returns>string</returns>
    private static string GenerateRefreshToken()
    {
        // Create a buffer to hold random bytes
        byte[] randomBytes = new byte[4]; // We need 2 random numbers, each fitting in an int (which is 4 bytes)

        // Generate the random bytes using RandomNumberGenerator
        RandomNumberGenerator.Fill(randomBytes);

        // Convert the first two bytes into a number between 0 and 999
        int firstPart = BitConverter.ToUInt16(randomBytes, 0) % 1000;

        // Convert the next two bytes into a number between 0 and 999
        int secondPart = BitConverter.ToUInt16(randomBytes, 2) % 1000;

        // Format the numbers to ensure they are 3 digits, padded with zeros if necessary
        return $"{firstPart:000}-{secondPart:000}";
    }
}
