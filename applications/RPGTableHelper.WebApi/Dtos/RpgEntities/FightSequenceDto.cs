using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

/// <summary>
/// Inline, ephemeral session payload (sse-06) carried by the <c>playersAreAskedForRolls</c> and
/// <c>dmReceivedFightSequenceAnswer</c> SSE events. Small enough to embed directly instead of round-tripping
/// through the revisioned config store.
/// </summary>
public class FightSequenceDto
{
    [Required]
    public string FightUuid { get; set; } = default!;

    [Required]
    public List<FightSequenceEntryDto> Sequence { get; set; } = new();
}
