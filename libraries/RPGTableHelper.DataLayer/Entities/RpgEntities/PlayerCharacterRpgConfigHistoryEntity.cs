using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    /// <summary>
    /// A single full-document snapshot of a player character's <see cref="PlayerCharacterEntity.RpgCharacterConfiguration"/>
    /// at a given revision. Only the last ~10 snapshots per character are retained, allowing clients to catch up via a
    /// JSON Patch from a recent revision instead of always re-downloading the full document.
    /// </summary>
    public class PlayerCharacterRpgConfigHistoryEntity : EntityBase<Guid>
    {
        [ForeignKey(nameof(PlayerCharacter))]
        public Guid PlayerCharacterId { get; set; } = Guid.Empty;
        public virtual PlayerCharacterEntity? PlayerCharacter { get; set; }

        /// <summary>
        /// The <see cref="PlayerCharacterEntity.RpgCharacterConfigurationRevision"/> this snapshot was taken at.
        /// </summary>
        public int Revision { get; set; }

        /// <summary>
        /// The full JSON document as it was at <see cref="Revision"/>.
        /// </summary>
        public string ConfigJson { get; set; } = default!;
    }
}
