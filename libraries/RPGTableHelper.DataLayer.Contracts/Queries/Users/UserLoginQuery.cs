using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserLoginQuery : IQuery<User.UserIdentifier, UserLoginQuery>
    {
        public string HashedPassword { get; set; } = default!;

        public string Username { get; set; } = default!;
    }
}
