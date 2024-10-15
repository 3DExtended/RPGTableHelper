using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserCredentialCreateQuery
        : CreateQuery<
            UserCredential,
            UserCredential.UserCredentialIdentifier,
            Guid,
            UserCredentialCreateQuery
        > { }
}
