using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class PlayerCharacterUpdateRpgConfigDto
{
    /// <summary>
    /// JSON-serialized player character configuration (full blob; server applies to DB).
    /// </summary>
    [Required]
    public string RpgCharacterConfiguration { get; set; } = default!;
}
