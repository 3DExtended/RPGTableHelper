using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions
{
    /// <summary>
    /// Revokes every non-revoked <c>AuthSession</c> for the given user ("sign out
    /// everywhere"). Prepared for a future UI; this slice only exposes it via API.
    /// </summary>
    public class RevokeAllAuthSessionsForUserQuery : IQuery<int, RevokeAllAuthSessionsForUserQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
