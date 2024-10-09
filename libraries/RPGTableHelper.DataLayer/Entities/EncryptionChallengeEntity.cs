using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class EncryptionChallengeEntity : EntityBase<Guid>
    {
        public string PasswordPrefix { get; set; } = default!;

        [ForeignKey(nameof(User))]
        public Guid UserId { get; set; }

        public virtual UserEntity User { get; set; } = default!;

        public int RndInt { get; set; }
    }
}
