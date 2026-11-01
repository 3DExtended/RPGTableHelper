using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    /// <summary>
    /// A fight in a campagne: who is asked to roll initiative, the rolls, and the order the DM settled on.
    /// Persisted so players who were offline when the DM started it are still asked once they come back,
    /// until the DM ends it. At most one fight per campagne is open (<see cref="EndedAt"/> is null).
    /// </summary>
    public class FightEntity : EntityBase<Guid>
    {
        [ForeignKey(nameof(Campagne))]
        public Guid CampagneId { get; set; } = Guid.Empty;
        public virtual CampagneEntity? Campagne { get; set; }

        public DateTimeOffset StartedAt { get; set; }

        /// <summary>Last change to the fight or its participants; drives the inactivity expiry.</summary>
        public DateTimeOffset LastActivityAt { get; set; }

        public DateTimeOffset? EndedAt { get; set; }

        public FightEndReason? EndReason { get; set; }

        /// <summary>Bumped on every change, so clients can tell whether their copy is current.</summary>
        public int Revision { get; set; }

        public virtual ICollection<FightParticipantEntity> Participants { get; set; } = new List<FightParticipantEntity>();
    }
}
