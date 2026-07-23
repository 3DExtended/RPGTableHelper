using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class CampagneUpdateRpgConfigDto
{
    /// <summary>
    /// JSON-serialized merged RPG configuration (legacy full blob).
    /// </summary>
    [Required]
    public string RpgConfiguration { get; set; } = default!;

    /// <summary>
    /// Optional failsafe revision check. When provided, the write is rejected with 409 if it does not match
    /// the server's current revision.
    /// </summary>
    public int? FromRevision { get; set; }
}
