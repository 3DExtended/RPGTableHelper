using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.Fights;

public class StartFightRequestDto
{
    /// <summary>Characters and companions to ask for initiative.</summary>
    [Required]
    public List<StartFightParticipantDto> Participants { get; set; } = new();

    /// <summary>Opponents with their rolls; more can be added later.</summary>
    public List<FightEnemyDto> Enemies { get; set; } = new();
}

public class StartFightParticipantDto
{
    /// <summary>The <c>uuid</c> inside the character configuration of the character or companion.</summary>
    [Required]
    public string CharacterUuid { get; set; } = default!;

    /// <summary>The player character it belongs to. Optional, but lets the server accept characters without a stored uuid.</summary>
    public Guid? PlayerCharacterId { get; set; }

    /// <summary>Optional display name; defaults to the name in the character configuration.</summary>
    public string? Name { get; set; }
}

public class FightEnemyDto
{
    [Required]
    public string Name { get; set; } = default!;

    [Required]
    public int Roll { get; set; }
}

public class AddFightEnemiesRequestDto
{
    [Required]
    public List<FightEnemyDto> Enemies { get; set; } = new();
}

public class ReorderFightRequestDto
{
    /// <summary>Every participant that has a roll, in the new order.</summary>
    [Required]
    public List<Guid> ParticipantIds { get; set; } = new();
}
