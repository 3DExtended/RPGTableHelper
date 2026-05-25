using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class CampagneUpdateRpgConfigDto
{
    /// <summary>
    /// JSON-serialized merged RPG configuration (legacy full blob).
    /// </summary>
    [Required]
    public string RpgConfiguration { get; set; } = default!;
}
