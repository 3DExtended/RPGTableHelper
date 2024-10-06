using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserDeleteQuery : IQuery<Unit, UserDeleteQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
