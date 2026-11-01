using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;

namespace RPGTableHelper.WebApi.Dtos.Fights;

/// <summary>
/// A fight as the caller may see it. The DM sees every participant, enemies included, in initiative order
/// followed by those still waiting to roll. A player sees only their own characters and companions, without
/// positions.
/// </summary>
public class FightDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    public Guid CampagneId { get; set; }

    [Required]
    public DateTimeOffset StartedAt { get; set; }

    public DateTimeOffset? EndedAt { get; set; }

    public FightEndReason? EndReason { get; set; }

    [Required]
    public bool IsOpen { get; set; }

    /// <summary>Increases with every change to the fight.</summary>
    [Required]
    public int Revision { get; set; }

    /// <summary>True if this is the DM's view with all participants.</summary>
    [Required]
    public bool IsDmView { get; set; }

    [Required]
    public List<FightParticipantDto> Participants { get; set; } = new();
}
