using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests
{
    public class OpenSignInProviderRegisterRequestCreateQuery
        : CreateQuery<
            OpenSignInProviderRegisterRequest,
            OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
            Guid,
            OpenSignInProviderRegisterRequestCreateQuery
        > { }
}
