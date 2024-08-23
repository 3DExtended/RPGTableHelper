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
}
