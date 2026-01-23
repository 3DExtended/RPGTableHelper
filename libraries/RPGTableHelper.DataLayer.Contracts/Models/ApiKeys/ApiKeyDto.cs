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
    }
}
