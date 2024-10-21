using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserExistsByUsernameQuery : IQuery<User.UserIdentifier, UserExistsByUsernameQuery>
    {
        public string Username { get; set; } = default!;
    }
}
