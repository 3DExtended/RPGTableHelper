using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query for user login.
    /// </summary>
    /// <typeparam name="User.UserIdentifier">The type of the user identifier returned by the query.</typeparam>
    /// <typeparam name="UserLoginQuery">The type of the query itself, enabling fluent interface patterns.</typeparam>

    public class UserLoginQuery : IQuery<User.UserIdentifier, UserLoginQuery>
    {
        public string HashedPassword { get; set; } = default!;

        public string Username { get; set; } = default!;
    }
}
