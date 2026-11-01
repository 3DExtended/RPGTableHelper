using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;

namespace RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys
{
    public class VerifyApiKeyQuery : IQuery<VerifiedApiKey, VerifyApiKeyQuery>
    {
        public string PlainApiKey { get; set; } = default!;
    }
}
