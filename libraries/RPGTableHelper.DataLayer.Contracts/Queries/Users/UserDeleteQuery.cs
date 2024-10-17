using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query to delete a user.
    /// </summary>
    public class UserDeleteQuery
        : DeleteCommand<User, User.UserIdentifier, Guid, UserDeleteQuery> { }
}
