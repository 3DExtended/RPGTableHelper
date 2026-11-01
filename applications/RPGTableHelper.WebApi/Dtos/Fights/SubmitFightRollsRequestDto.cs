using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.Fights;

public class SubmitFightRollsRequestDto
{
    [Required]
    public List<FightRollDto> Rolls { get; set; } = new();
}

public class FightRollDto
{
    /// <summary>The <c>uuid</c> of the character or companion, as listed in the fight.</summary>
    [Required]
    public string CharacterUuid { get; set; } = default!;

    /// <summary>The initiative total, modifiers included.</summary>
    [Required]
    public int Roll { get; set; }
}
