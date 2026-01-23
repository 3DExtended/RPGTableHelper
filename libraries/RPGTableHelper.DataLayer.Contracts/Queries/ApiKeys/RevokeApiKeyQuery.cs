using System;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys
{
    // Returning bool to indicate success/failure, or just completion.
    // Ideally use a Unit type if available, but bool is safe.
    public class RevokeApiKeyQuery : IQuery<bool, RevokeApiKeyQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
        public Guid ApiKeyId { get; set; }
    }
}
