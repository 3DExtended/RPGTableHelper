using System.Security.Cryptography;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.SignalR;

namespace RPGTableHelper.WebApi;

public class ChatHub : Hub
{
    // public void Send(string name, string message)
    // {
    //     Console.WriteLine("name: " + name + ", message: " + message);
    //     // Call the "OnMessage" method to update clients.
    //     Clients.All.SendAsync("OnMessage", name, message);
    // }

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
