namespace RPGTableHelper.WebApi.Services.Presence;

/// <summary>
/// Tracks table session presence (separate from campagne membership) for already-accepted DM/players.
/// Online status combines an explicit <see cref="EnterAsync"/> with SSE liveness, using a short grace
/// period on SSE disconnect so brief reconnects do not flicker offline.
/// </summary>
public interface ISessionPresenceService
{
    /// <summary>
    /// Marks <paramref name="userId"/> as present for a table session in <paramref name="campagneId"/>.
    /// Emits <c>participantOnline</c> to other participants currently in session for this campagne.
    /// </summary>
    Task EnterAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// Marks <paramref name="userId"/> as no longer present for a table session in <paramref name="campagneId"/>.
    /// Emits <c>participantOffline</c> to remaining participants.
    /// </summary>
    Task LeaveAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// Call when an SSE connection for <paramref name="userId"/> is established (including reconnects).
    /// Cancels any pending grace-period offline transition.
    /// </summary>
    Task OnSseConnectedAsync(Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// Call when <paramref name="userId"/> no longer has any active SSE connection. Schedules an offline
    /// transition after the grace period unless a reconnect cancels it first via <see cref="OnSseConnectedAsync"/>.
    /// </summary>
    Task OnSseDisconnectedAsync(Guid userId, CancellationToken cancellationToken);

    /// <summary>
    /// True if <paramref name="userId"/> is currently marked online for <paramref name="campagneId"/>.
    /// </summary>
    bool IsOnline(Guid campagneId, Guid userId);
}
