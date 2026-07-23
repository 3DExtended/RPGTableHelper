using System.Collections.Concurrent;

namespace RPGTableHelper.WebApi.Services.Sse;

public sealed class SseEventHub : ISseEventHub
{
    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, Func<string, string, CancellationToken, Task>>> _connections =
        new();

    public IAsyncDisposable Register(Guid userId, Func<string, string, CancellationToken, Task> writeEventAsync)
    {
        var connectionId = Guid.NewGuid();
        var userConnections = _connections.GetOrAdd(
            userId,
            _ => new ConcurrentDictionary<Guid, Func<string, string, CancellationToken, Task>>()
        );
        userConnections[connectionId] = writeEventAsync;
        return new Registration(this, userId, connectionId);
    }

    public async Task SendToUserAsync(
        Guid userId,
        string eventType,
        string dataJson,
        CancellationToken cancellationToken
    )
    {
        if (!_connections.TryGetValue(userId, out var userConnections))
        {
            return;
        }

        foreach (var writer in userConnections.Values.ToArray())
        {
            try
            {
                await writer(eventType, dataJson, cancellationToken).ConfigureAwait(false);
            }
            catch
            {
                // Writer may already be closed; registration dispose cleans up.
            }
        }
    }

    public async Task SendToUsersAsync(
        IEnumerable<Guid> userIds,
        string eventType,
        string dataJson,
        CancellationToken cancellationToken
    )
    {
        foreach (var userId in userIds.Distinct())
        {
            await SendToUserAsync(userId, eventType, dataJson, cancellationToken).ConfigureAwait(false);
        }
    }

    private void Unregister(Guid userId, Guid connectionId)
    {
        if (!_connections.TryGetValue(userId, out var userConnections))
        {
            return;
        }

        userConnections.TryRemove(connectionId, out _);
        if (userConnections.IsEmpty)
        {
            _connections.TryRemove(userId, out _);
        }
    }

    private sealed class Registration : IAsyncDisposable
    {
        private readonly SseEventHub _hub;
        private readonly Guid _userId;
        private readonly Guid _connectionId;
        private int _disposed;

        public Registration(SseEventHub hub, Guid userId, Guid connectionId)
        {
            _hub = hub;
            _userId = userId;
            _connectionId = connectionId;
        }

        public ValueTask DisposeAsync()
        {
            if (Interlocked.Exchange(ref _disposed, 1) == 0)
            {
                _hub.Unregister(_userId, _connectionId);
            }

            return ValueTask.CompletedTask;
        }
    }
}
