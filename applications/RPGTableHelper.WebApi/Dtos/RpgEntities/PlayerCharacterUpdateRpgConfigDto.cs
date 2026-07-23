using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class PlayerCharacterUpdateRpgConfigDto
{
    /// <summary>
    /// JSON-serialized player character configuration (full blob; server applies to DB).
    /// </summary>
    [Required]
    public string RpgCharacterConfiguration { get; set; } = default!;

    /// <summary>
    /// Optional failsafe revision check. When provided, the write is rejected with 409 if it does not match
    /// the server's current revision.
    /// </summary>
    public int? FromRevision { get; set; }
}
