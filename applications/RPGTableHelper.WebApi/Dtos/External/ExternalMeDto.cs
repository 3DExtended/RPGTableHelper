using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>Who the API key belongs to and what it may do.</summary>
public class ExternalMeDto
{
    [Required]
    public Guid UserId { get; set; }

    [Required]
    public string Username { get; set; } = default!;

    [Required]
    public ExternalApiKeyInfoDto ApiKey { get; set; } = default!;
}

public class ExternalApiKeyInfoDto
{
    /// <summary>The non-secret start of the key, as shown in Questkeeper's key list.</summary>
    [Required]
    public string Prefix { get; set; } = default!;

    /// <summary>The permissions of this key, e.g. <c>notes:write</c>.</summary>
    [Required]
    public List<string> Scopes { get; set; } = new();
}
