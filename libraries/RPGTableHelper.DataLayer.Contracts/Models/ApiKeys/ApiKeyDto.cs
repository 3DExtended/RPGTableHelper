using System;

namespace RPGTableHelper.DataLayer.Contracts.Models.ApiKeys
{
    public class ApiKeyDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = default!;
        public string Prefix { get; set; } = default!;
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? RevokedAt { get; set; }
        public List<string> Scopes { get; set; } = new();
        public DateTimeOffset? LastUsedAt { get; set; }
        public DateTimeOffset? ExpiresAt { get; set; }
    }
}
