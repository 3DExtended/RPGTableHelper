using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Base;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserCreateQuery
        : ConditionalCreateQueryBase<User, User.UserIdentifier, Guid, UserCreateQuery>
    {
        public UserCredentials? UserCredentials { get; set; }
    }
}
