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
    }
}
