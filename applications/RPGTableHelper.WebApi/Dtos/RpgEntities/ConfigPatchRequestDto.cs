using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class ConfigPatchRequestDto
{
    /// <summary>
    /// The revision the client's patch was computed against. Must match the server's current revision,
    /// otherwise the request fails with 409 so the client can rebase and retry.
    /// </summary>
    [Required]
    public int FromRevision { get; set; }

    /// <summary>
    /// RFC 6902 JSON Patch document, serialized as a JSON array string.
    /// </summary>
    [Required]
    public string Patch { get; set; } = default!;
}
