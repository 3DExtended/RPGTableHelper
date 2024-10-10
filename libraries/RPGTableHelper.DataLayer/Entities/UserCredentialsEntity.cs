using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class UserCredentialEntity : EntityBase<Guid>
    {
        public bool Deleted { get; set; } = false;

        public string? Email { get; set; }

        public bool? EmailVerified { get; set; } = false;

        [ForeignKey(nameof(EncryptionChallengeOfUser))]
        public Guid? EncryptionChallengeId { get; set; }

        public virtual EncryptionChallengeEntity? EncryptionChallengeOfUser { get; set; }

        public string? HashedPassword { get; set; }

        public string? PasswordResetToken { get; set; }

        public DateTimeOffset? PasswordResetTokenExpireDate { get; set; }

        public string? RefreshToken { get; set; }

        public bool SignInProvider { get; set; } = false;

        [ForeignKey(nameof(User))]
        public Guid UserId { get; set; } = default!;

        public virtual UserEntity? User { get; set; }
    }
}
