using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class EncryptionChallengeEntity : EntityBase<Guid>
    {
        public string PasswordPrefix { get; set; } = default!;

        public int RndInt { get; set; }
    }
}
