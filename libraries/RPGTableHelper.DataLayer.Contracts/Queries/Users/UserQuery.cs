using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query for retrieving a single User entity.
    /// </summary>
    public class UserQuery : SingleModelQuery<User, User.UserIdentifier, Guid, UserQuery> { }
}
