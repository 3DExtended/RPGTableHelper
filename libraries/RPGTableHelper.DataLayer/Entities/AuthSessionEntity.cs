using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class AuthSessionEntity : EntityBase<Guid>
    {
        public Guid UserId { get; set; }
        public UserEntity User { get; set; } = default!;
        public string TokenHash { get; set; } = default!;
        public DateTimeOffset ExpiresAt { get; set; }

        // Nullable rotation/grace fields, prepared for auth-02 (refresh rotation) but unused by auth-01.
        public string? PreviousTokenHash { get; set; }
        public DateTimeOffset? PreviousTokenExpiresAt { get; set; }
        public DateTimeOffset? RevokedAt { get; set; }
    }
}
