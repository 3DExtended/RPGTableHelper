using Microsoft.AspNetCore.SignalR;

namespace RPGTableHelper.WebApi;

public class ChatHub : Hub
{
    public void Send(string name, string message)
    {
        Console.WriteLine("name: " + name + ", message: " + message);
        // Call the "OnMessage" method to update clients.
        Clients.All.SendAsync("OnMessage", name, message);
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
}
