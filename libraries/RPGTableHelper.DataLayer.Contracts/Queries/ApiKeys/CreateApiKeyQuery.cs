using System;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys
{
    public class CreateApiKeyQuery : IQuery<CreateApiKeyResponse, CreateApiKeyQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
        public string Name { get; set; } = default!;
        public IReadOnlyCollection<string> Scopes { get; set; } = Array.Empty<string>();

        /// <summary>When the key stops working; none for a key that never expires.</summary>
        public Option<DateTimeOffset> ExpiresAt { get; set; } = Option.None;
    }
}
