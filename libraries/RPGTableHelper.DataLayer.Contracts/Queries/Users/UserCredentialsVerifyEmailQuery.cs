using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserCredentialsVerifyEmailQuery : IQuery<Unit, UserCredentialsVerifyEmailQuery>
    {
        public User.UserIdentifier UserIdentifier { get; set; } = default!;
    }
}
