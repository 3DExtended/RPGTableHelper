using RPGTableHelper.DataLayer.Contracts.Models;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Base;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserCredentialsCreateQuery
        : ConditionalCreateQueryBase<
            UserCredentials,
            UserCredentials.UserCredentialsIdentifier,
            Guid,
            UserCredentialsCreateQuery
        > { }
}
