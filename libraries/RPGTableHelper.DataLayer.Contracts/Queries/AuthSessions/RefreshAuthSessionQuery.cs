using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.AuthSessions;

namespace RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions
{
    /// <summary>
    /// Presents a plaintext refresh token and, if it (or its immediate predecessor, within
    /// grace) matches a live auth session, rotates that session and mints a new refresh token.
    ///
    /// Presenting a token that matches a rotated-away predecessor after its grace window
    /// revokes that session (theft/reuse protection) and this returns None. Unknown, expired
    /// or already-revoked tokens also return None, with no side effects.
    /// </summary>
    public class RefreshAuthSessionQuery : IQuery<RefreshAuthSessionResponse, RefreshAuthSessionQuery>
    {
        public string PlainRefreshToken { get; set; } = default!;

        /// <summary>
        /// Lifetime (in seconds) to assign to the newly minted refresh token, counted from now.
        /// </summary>
        public long NewRefreshTokenLifetimeSeconds { get; set; }

        /// <summary>
        /// How long (in seconds) the rotated-away previous token stays acceptable after rotation.
        /// </summary>
        public long GracePeriodSeconds { get; set; }
    }
}
