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

        /// <summary>
        /// Cold (rarely changing) slice of <see cref="RpgConfiguration"/>.
        /// Backfilled from <see cref="RpgConfiguration"/> for legacy campagnes.
        /// </summary>
        public string? RpgConfigurationCold { get; set; }

        /// <summary>
        /// Hot (frequently changing) slice of <see cref="RpgConfiguration"/>.
        /// Backfilled from <see cref="RpgConfiguration"/> for legacy campagnes.
        /// </summary>
        public string? RpgConfigurationHot { get; set; }

        /// <summary>
        /// Schema version for the cold/hot split format. 0/NULL = unknown/legacy.
        /// </summary>
        public int? RpgConfigurationSchemaVersion { get; set; }

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
