using System.Collections.Concurrent;
using System.Text.Json;

using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Services.Presence;

public sealed class SessionPresenceService : ISessionPresenceService
{
    private static readonly TimeSpan DefaultGracePeriod = TimeSpan.FromSeconds(20);

    private readonly ISseEventHub _sseEventHub;
    private readonly TimeSpan _gracePeriod;

    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, byte>> _participantsByCampagne = new();
    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, byte>> _campagnesByUser = new();
    private readonly ConcurrentDictionary<Guid, CancellationTokenSource> _pendingOfflineGraceByUser = new();

    public SessionPresenceService(ISseEventHub sseEventHub, TimeSpan? gracePeriod = null)
    {
        _sseEventHub = sseEventHub;
        _gracePeriod = gracePeriod ?? DefaultGracePeriod;
    }

    public async Task EnterAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken)
    {
        CancelPendingGrace(userId);

        var participants = _participantsByCampagne.GetOrAdd(campagneId, static _ => new ConcurrentDictionary<Guid, byte>());
        var wasAlreadyOnline = participants.ContainsKey(userId);
        participants[userId] = 0;

        var campagnes = _campagnesByUser.GetOrAdd(userId, static _ => new ConcurrentDictionary<Guid, byte>());
        campagnes[campagneId] = 0;

        if (!wasAlreadyOnline)
        {
            await BroadcastAsync(campagneId, userId, "participantOnline", cancellationToken).ConfigureAwait(false);
        }
    }

    public async Task LeaveAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken)
    {
        var wasOnline = RemoveParticipant(campagneId, userId);

        if (wasOnline)
        {
            await BroadcastAsync(campagneId, userId, "participantOffline", cancellationToken).ConfigureAwait(false);
        }
    }

    public Task OnSseConnectedAsync(Guid userId, CancellationToken cancellationToken)
    {
        CancelPendingGrace(userId);
        return Task.CompletedTask;
    }

    public Task OnSseDisconnectedAsync(Guid userId, CancellationToken cancellationToken)
    {
        CancelPendingGrace(userId);

        if (!_campagnesByUser.TryGetValue(userId, out var campagnes) || campagnes.IsEmpty)
        {
            // Not currently in any table session, nothing to expire.
            return Task.CompletedTask;
        }

        var cts = new CancellationTokenSource();
        _pendingOfflineGraceByUser[userId] = cts;

        _ = ExpireAfterGraceAsync(userId, cts);

        return Task.CompletedTask;
    }

    public bool IsOnline(Guid campagneId, Guid userId) =>
        _participantsByCampagne.TryGetValue(campagneId, out var participants)
        && participants.ContainsKey(userId)
        && IsLiveOrInGrace(userId);

    public IReadOnlyCollection<Guid> GetOnlineParticipants(Guid campagneId)
    {
        if (!_participantsByCampagne.TryGetValue(campagneId, out var participants))
        {
            return Array.Empty<Guid>();
        }

        // Snapshot keys so we can prune zombies while iterating.
        var candidateIds = participants.Keys.ToList();
        var result = new List<Guid>(candidateIds.Count);

        foreach (var userId in candidateIds)
        {
            if (IsLiveOrInGrace(userId))
            {
                result.Add(userId);
                continue;
            }

            // Entered the session but has no live SSE and no grace timer — typical
            // after a hard app kill where the SSE request never observed disconnect.
            // Drop them so SessionEnter snapshots do not show ghost "online" players.
            if (RemoveParticipant(campagneId, userId))
            {
                _ = BroadcastAsync(campagneId, userId, "participantOffline", CancellationToken.None);
            }
        }

        return result;
    }

    /// <summary>
    /// True while the user has an active SSE connection, or is inside the brief
    /// reconnect grace window after an observed SSE disconnect.
    /// </summary>
    private bool IsLiveOrInGrace(Guid userId) =>
        _sseEventHub.HasConnection(userId) || _pendingOfflineGraceByUser.ContainsKey(userId);

    private async Task ExpireAfterGraceAsync(Guid userId, CancellationTokenSource cts)
    {
        try
        {
            await Task.Delay(_gracePeriod, cts.Token).ConfigureAwait(false);
        }
        catch (OperationCanceledException)
        {
            return;
        }

        // Reconnect may have raced us and already replaced/cancelled this token; only proceed if we're still current.
        if (!_pendingOfflineGraceByUser.TryRemove(userId, out var currentCts) || !ReferenceEquals(currentCts, cts))
        {
            return;
        }

        cts.Dispose();

        if (!_campagnesByUser.TryRemove(userId, out var campagnes))
        {
            return;
        }

        foreach (var campagneId in campagnes.Keys)
        {
            if (RemoveParticipant(campagneId, userId))
            {
                await BroadcastAsync(campagneId, userId, "participantOffline", CancellationToken.None).ConfigureAwait(false);
            }
        }
    }

    private bool RemoveParticipant(Guid campagneId, Guid userId)
    {
        var removed = false;

        if (_participantsByCampagne.TryGetValue(campagneId, out var participants))
        {
            removed = participants.TryRemove(userId, out _);
            if (participants.IsEmpty)
            {
                _participantsByCampagne.TryRemove(campagneId, out _);
            }
        }

        if (_campagnesByUser.TryGetValue(userId, out var campagnes))
        {
            campagnes.TryRemove(campagneId, out _);
        }

        return removed;
    }

    private void CancelPendingGrace(Guid userId)
    {
        if (_pendingOfflineGraceByUser.TryRemove(userId, out var cts))
        {
            cts.Cancel();
            cts.Dispose();
        }
    }

    private Task BroadcastAsync(Guid campagneId, Guid userId, string eventType, CancellationToken cancellationToken)
    {
        if (!_participantsByCampagne.TryGetValue(campagneId, out var participants))
        {
            return Task.CompletedTask;
        }

        var recipients = participants.Keys.Where(id => id != userId).ToList();
        if (recipients.Count == 0)
        {
            return Task.CompletedTask;
        }

        var payload = JsonSerializer.Serialize(new { campagneId = campagneId.ToString(), userId = userId.ToString() });
        return _sseEventHub.SendToUsersAsync(recipients, eventType, payload, cancellationToken);
    }
}
