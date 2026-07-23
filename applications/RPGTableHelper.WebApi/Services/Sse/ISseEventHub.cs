namespace RPGTableHelper.WebApi.Services.Sse;

/// <summary>
/// In-process fan-out of Server-Sent Events to authenticated user connections.
/// </summary>
public interface ISseEventHub
{
    /// <summary>
    /// Registers a writer for <paramref name="userId"/>. Disposing the returned handle unregisters it.
    /// </summary>
    IAsyncDisposable Register(Guid userId, Func<string, string, CancellationToken, Task> writeEventAsync);

    /// <summary>
    /// True if <paramref name="userId"/> currently has at least one registered connection.
    /// </summary>
    bool HasConnection(Guid userId);

    Task SendToUserAsync(Guid userId, string eventType, string dataJson, CancellationToken cancellationToken);

    Task SendToUsersAsync(
        IEnumerable<Guid> userIds,
        string eventType,
        string dataJson,
        CancellationToken cancellationToken
    );
}
