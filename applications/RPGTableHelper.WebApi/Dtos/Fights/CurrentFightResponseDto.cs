namespace RPGTableHelper.WebApi.Dtos.Fights;

public class CurrentFightResponseDto
{
    /// <summary>The open fight of the campagne, or null if there is none.</summary>
    public FightDto? Fight { get; set; }
}
