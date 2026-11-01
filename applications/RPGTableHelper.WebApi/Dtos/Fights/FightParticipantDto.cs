using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;

namespace RPGTableHelper.WebApi.Dtos.Fights;

public class FightParticipantDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    public FightParticipantKind Kind { get; set; }

    /// <summary>The <c>uuid</c> inside the character configuration; null for enemies.</summary>
    public string? CharacterUuid { get; set; }

    /// <summary>The player character this participant belongs to; null for enemies.</summary>
    public Guid? PlayerCharacterId { get; set; }

    [Required]
    public string Name { get; set; } = default!;

    /// <summary>Null while the participant waits for its owner to roll.</summary>
    public int? Roll { get; set; }

    public DateTimeOffset? RolledAt { get; set; }

    /// <summary>Place in the initiative order, starting at 0. Only in the DM's view.</summary>
    public int? Position { get; set; }

    /// <summary>True while the owner still has to roll for this participant.</summary>
    [Required]
    public bool IsPending { get; set; }
}
