using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities
{
    /// <summary>
    /// One combatant in a <see cref="FightEntity"/>. Characters and companions start without a roll (pending)
    /// until their owner rolls; enemies are added by the DM with a roll.
    /// </summary>
    public class FightParticipantEntity : EntityBase<Guid>
    {
        [ForeignKey(nameof(Fight))]
        public Guid FightId { get; set; } = Guid.Empty;
        public virtual FightEntity? Fight { get; set; }

        public FightParticipantKind Kind { get; set; }

        /// <summary>The <c>uuid</c> inside the character configuration (character or companion); null for enemies.</summary>
        public string? CharacterUuid { get; set; }

        /// <summary>The player character this participant belongs to; null for enemies.</summary>
        public Guid? PlayerCharacterId { get; set; }

        /// <summary>The user who is asked to roll for this participant; null for enemies.</summary>
        public Guid? OwnerUserId { get; set; }

        public string Name { get; set; } = default!;

        /// <summary>Null while the owner has not rolled yet.</summary>
        public int? Roll { get; set; }

        public DateTimeOffset? RolledAt { get; set; }

        /// <summary>Place in the initiative order, starting at 0; null while the participant has no roll.</summary>
        public int? Position { get; set; }
    }
}
