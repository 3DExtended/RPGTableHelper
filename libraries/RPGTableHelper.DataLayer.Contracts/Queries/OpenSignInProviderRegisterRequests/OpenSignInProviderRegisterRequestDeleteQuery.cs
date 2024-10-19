using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests
{
    /// <summary>
    /// Represents a query to delete a user.
    /// </summary>
    public class OpenSignInProviderRegisterRequestDeleteQuery
        : DeleteCommand<
            OpenSignInProviderRegisterRequest,
            OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
            Guid,
            OpenSignInProviderRegisterRequestDeleteQuery
        > { }
}
