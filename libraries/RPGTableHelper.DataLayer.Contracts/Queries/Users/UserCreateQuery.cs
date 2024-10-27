using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserCreateQuery : CreateQuery<User, User.UserIdentifier, Guid, UserCreateQuery> { }
}
