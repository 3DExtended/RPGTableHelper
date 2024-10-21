using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    public class PlayerCharacterEntity : EntityBase<Guid>
    {
        /// <summary>
        /// This is the json serialized configuration of the character
        /// </summary>
        public string? RpgCharacterConfiguration { get; set; }

        public string CharacterName { get; set; } = default!;

        /// <summary>
        /// The user of this character
        /// </summary>
        [ForeignKey(nameof(PlayerUser))]
        public Guid PlayerUserId { get; set; } = Guid.Empty;
        public virtual UserEntity? PlayerUser { get; set; }

        /// <summary>
        /// The id of the campagne for this character
        /// </summary>
        [ForeignKey(nameof(Campagne))]
        public Guid? CampagneId { get; set; }
        public virtual CampagneEntity? Campagne { get; set; }
    }
}
