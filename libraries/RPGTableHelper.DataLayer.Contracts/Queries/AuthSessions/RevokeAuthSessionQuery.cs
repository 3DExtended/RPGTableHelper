using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions
{
    /// <summary>
    /// Revokes the single <c>AuthSession</c> matching the presented plaintext refresh
    /// token (whether it is the session's current or most-recently-rotated-away
    /// token), clearing its grace-window predecessor so it can no longer be used
    /// either. Used by logout, where the client has no session id and only the
    /// refresh token to identify "this device's session".
    ///
    /// Returns <c>true</c> if a matching session was found and revoked, or
    /// <see cref="Option{T}.None"/> if no session matches (unknown token) - callers
    /// should treat both as a successful, idempotent logout from the client's
    /// perspective.
    /// </summary>
    public class RevokeAuthSessionQuery : IQuery<bool, RevokeAuthSessionQuery>
    {
        public string PlainRefreshToken { get; set; } = default!;
    }
}
