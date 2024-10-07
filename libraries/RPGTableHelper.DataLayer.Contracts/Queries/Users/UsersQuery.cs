using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UsersQuery : ListOfModelQuery<User, User.UserIdentifier, Guid, UsersQuery> { }
}
