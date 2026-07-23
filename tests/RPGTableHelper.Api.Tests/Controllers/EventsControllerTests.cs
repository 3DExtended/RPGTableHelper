using System.Net;
using System.Text;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Controllers;

public class EventsControllerTests : ControllerTestBase
{
    public EventsControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task GetEvents_WithoutAuth_ReturnsUnauthorized()
    {
        Client.DefaultRequestHeaders.Authorization = null;

        var response = await Client.GetAsync("/events");

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetEvents_WithAuth_StreamsHelloEvent()
    {
        var user = await ConfigureLoggedInUser();

        using var request = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var response = await Client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead);
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        response.Content.Headers.ContentType!.MediaType.Should().Be("text/event-stream");

        await using var stream = await response.Content.ReadAsStreamAsync();
        using var reader = new StreamReader(stream, Encoding.UTF8);

        var line1 = await reader.ReadLineAsync();
        var line2 = await reader.ReadLineAsync();

        line1.Should().Be("event: hello");
        line2.Should().StartWith("data:");
        line2.Should().Contain(user.Id.Value.ToString());
    }

    [Fact]
    public async Task SseEventHub_CanPushEventToConnectedUser()
    {
        var user = await ConfigureLoggedInUser();
        var hub = Factory.Services.GetRequiredService<ISseEventHub>();

        using var request = new HttpRequestMessage(HttpMethod.Get, "/events");
        using var response = await Client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead);
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync();
        using var reader = new StreamReader(stream, Encoding.UTF8);

        // Drain hello
        _ = await reader.ReadLineAsync();
        _ = await reader.ReadLineAsync();
        _ = await reader.ReadLineAsync(); // blank line after event

        await hub.SendToUserAsync(
            user.Id.Value,
            "testEvent",
            """{"ok":true}""",
            CancellationToken.None);

        var eventLine = await reader.ReadLineAsync();
        var dataLine = await reader.ReadLineAsync();

        eventLine.Should().Be("event: testEvent");
        dataLine.Should().Be("data: {\"ok\":true}");
    }
}
