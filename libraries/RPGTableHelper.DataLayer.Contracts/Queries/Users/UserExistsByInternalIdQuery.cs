using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query to check if a user exists by their internal ID.
    /// </summary>
    /// <remarks>
    /// This query returns a <see cref="User.UserIdentifier"/> to indicate the existence of the user.
    /// </remarks>
    public class UserExistsByInternalIdQuery
        : IQuery<User.UserIdentifier, UserExistsByInternalIdQuery>
    {
        public string SignInProviderId { get; set; } = default!;
    }
}
