using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    public class CampagneEntity : EntityBase<Guid>
    {
        /// <summary>
        /// This is the json serialized configuration of the rpg
        /// </summary>
        public string? RpgConfiguration { get; set; }

        public string CampagneName { get; set; } = default!;
        public string JoinCode { get; set; } = default!;

        /// <summary>
        /// The dm of this campagne.
        /// </summary>
        [ForeignKey(nameof(DmUser))]
        public Guid DmUserId { get; set; } = Guid.Empty;
        public virtual UserEntity? DmUser { get; set; }

        public ICollection<PlayerCharacterEntity>? Characters { get; }
    }
}
