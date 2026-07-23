using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Controllers;

[ApiController]
[Authorize]
[Route("events")]
public class EventsController : ControllerBase
{
    private readonly ISseEventHub _sseEventHub;
    private readonly IUserContext _userContext;

    public EventsController(ISseEventHub sseEventHub, IUserContext userContext)
    {
        _sseEventHub = sseEventHub;
        _userContext = userContext;
    }

    /// <summary>
    /// Long-lived Server-Sent Events stream for the authenticated user.
    /// </summary>
    [HttpGet]
    public async Task GetEvents(CancellationToken cancellationToken)
    {
        var userId = Guid.Parse(_userContext.User.IdentityProviderId);

        Response.Headers.ContentType = "text/event-stream";
        Response.Headers.CacheControl = "no-cache";
        Response.Headers.Connection = "keep-alive";
        Response.Headers["X-Accel-Buffering"] = "no";

        await Response.Body.FlushAsync(cancellationToken).ConfigureAwait(false);

        var writeLock = new SemaphoreSlim(1, 1);

        await using var registration = _sseEventHub.Register(
            userId,
            async (eventType, dataJson, ct) =>
            {
                await WriteSseEventAsync(writeLock, eventType, dataJson, ct).ConfigureAwait(false);
            }
        );

        await WriteSseEventAsync(
                writeLock,
                "hello",
                JsonSerializer.Serialize(new { userId = userId.ToString() }),
                cancellationToken
            )
            .ConfigureAwait(false);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromSeconds(15), cancellationToken).ConfigureAwait(false);
                await WriteSseCommentAsync(writeLock, "keepalive", cancellationToken).ConfigureAwait(false);
            }
        }
        catch (OperationCanceledException)
        {
            // Client disconnected.
        }
    }

    private async Task WriteSseEventAsync(
        SemaphoreSlim writeLock,
        string eventType,
        string dataJson,
        CancellationToken cancellationToken
    )
    {
        await writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var payload = $"event: {eventType}\ndata: {dataJson}\n\n";
            var bytes = Encoding.UTF8.GetBytes(payload);
            await Response.Body.WriteAsync(bytes, cancellationToken).ConfigureAwait(false);
            await Response.Body.FlushAsync(cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            writeLock.Release();
        }
    }

    private async Task WriteSseCommentAsync(
        SemaphoreSlim writeLock,
        string comment,
        CancellationToken cancellationToken
    )
    {
        await writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var payload = $": {comment}\n\n";
            var bytes = Encoding.UTF8.GetBytes(payload);
            await Response.Body.WriteAsync(bytes, cancellationToken).ConfigureAwait(false);
            await Response.Body.FlushAsync(cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            writeLock.Release();
        }
    }
}
