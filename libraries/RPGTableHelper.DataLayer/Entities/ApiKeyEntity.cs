using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class ApiKeyEntity : EntityBase<Guid>
    {
        public Guid UserId { get; set; }
        public UserEntity User { get; set; } = default!;
        public string Name { get; set; } = default!;
        public string KeyHash { get; set; } = default!;
        public string Prefix { get; set; } = default!;
        public DateTimeOffset? RevokedAt { get; set; }

        /// <summary>Granted scopes, space-separated (see <c>ApiKeyScopes</c>).</summary>
        public string Scopes { get; set; } = string.Empty;

        /// <summary>Updated at most once a minute while the key is in use.</summary>
        public DateTimeOffset? LastUsedAt { get; set; }

        /// <summary>The key stops working after this point in time; <c>null</c> means it never expires.</summary>
        public DateTimeOffset? ExpiresAt { get; set; }
    }
}
