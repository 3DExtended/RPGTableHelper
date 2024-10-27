using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class EncryptionChallengeEntity : EntityBase<Guid>
    {
        public string PasswordPrefix { get; set; } = default!;

        /// <summary>
        /// Is not yet set if the user is in the process of signing up
        /// </summary>
        [ForeignKey(nameof(User))]
        public Guid? UserId { get; set; }

        public virtual UserEntity? User { get; set; }

        public int RndInt { get; set; }
    }
}
