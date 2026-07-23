namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class ConfigSnapshotResponseDto
{
    /// <summary>"patch" or "full".</summary>
    public string Kind { get; set; } = default!;

    /// <summary>The current revision on the server.</summary>
    public int Revision { get; set; }

    /// <summary>The revision the returned <see cref="Patch"/> was computed from. Only set when <see cref="Kind"/> is "patch".</summary>
    public int? FromRevision { get; set; }

    /// <summary>The full JSON document. Only set when <see cref="Kind"/> is "full".</summary>
    public string? FullConfig { get; set; }

    /// <summary>RFC 6902 JSON Patch document, serialized as a JSON array string. Only set when <see cref="Kind"/> is "patch".</summary>
    public string? Patch { get; set; }
}
