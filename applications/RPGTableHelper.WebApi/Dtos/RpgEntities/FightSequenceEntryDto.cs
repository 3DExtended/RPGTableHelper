using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

/// <summary>
/// A single combatant's roll in a fight sequence. <see cref="CharacterId"/> is <c>null</c> for opponents the
/// DM added manually to the fight (not backed by a player character).
/// </summary>
public class FightSequenceEntryDto
{
    public string? CharacterId { get; set; }

    [Required]
    public string CharacterName { get; set; } = default!;

    public int Roll { get; set; }
}
