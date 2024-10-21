using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests
{
    public class OpenSignInProviderRegisterRequestExistsByApiKeyQuery
        : IQuery<
            OpenSignInProviderRegisterRequest,
            OpenSignInProviderRegisterRequestExistsByApiKeyQuery
        >
    {
        public string ApiKey { get; set; } = default!;
    }
}
