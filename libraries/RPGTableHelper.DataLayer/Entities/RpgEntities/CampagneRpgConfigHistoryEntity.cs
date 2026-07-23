using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    /// <summary>
    /// A single full-document snapshot of a campagne's <see cref="CampagneEntity.RpgConfiguration"/> at a given revision.
    /// Only the last ~10 snapshots per campagne are retained, allowing clients to catch up via a JSON Patch
    /// from a recent revision instead of always re-downloading the full document.
    /// </summary>
    public class CampagneRpgConfigHistoryEntity : EntityBase<Guid>
    {
        [ForeignKey(nameof(Campagne))]
        public Guid CampagneId { get; set; } = Guid.Empty;
        public virtual CampagneEntity? Campagne { get; set; }

        /// <summary>
        /// The <see cref="CampagneEntity.RpgConfigurationMergedRevision"/> this snapshot was taken at.
        /// </summary>
        public int Revision { get; set; }

        /// <summary>
        /// The full JSON document as it was at <see cref="Revision"/>.
        /// </summary>
        public string ConfigJson { get; set; } = default!;
    }
}
