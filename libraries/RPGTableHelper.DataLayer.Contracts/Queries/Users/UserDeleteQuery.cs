using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query to delete a user.
    /// </summary>
    public class UserDeleteQuery : IQuery<Unit, UserDeleteQuery>
    {
        /// <summary>
        /// Gets or sets the identifier of the user to be deleted.
        /// </summary>
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
