using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys
{
    public class VerifyApiKeyQuery : IQuery<User, VerifyApiKeyQuery>
    {
        public string PlainApiKey { get; set; } = default!;
    }
}
