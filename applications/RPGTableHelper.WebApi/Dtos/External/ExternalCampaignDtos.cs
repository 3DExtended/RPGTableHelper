using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>Someone at the campaign's table: the DM, or a player with at least one character in it.</summary>
public class ExternalCampaignMemberDto
{
    /// <summary>Use this id in a note block's <c>visibleTo</c>.</summary>
    [Required]
    public Guid UserId { get; set; }

    [Required]
    public bool IsDm { get; set; }

    /// <summary>True for the owner of the API key.</summary>
    [Required]
    public bool IsYou { get; set; }

    /// <summary>The member's characters in this campaign; empty for the DM.</summary>
    [Required]
    public List<ExternalCharacterRefDto> Characters { get; set; } = new();
}

public class ExternalCharacterRefDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    public string Name { get; set; } = default!;
}

/// <summary>The campaign's rule configuration: stat definitions, items, currencies and so on.</summary>
public class ExternalCampaignConfigDto
{
    [Required]
    public Guid CampaignId { get; set; }

    /// <summary>Increases with every change to the configuration.</summary>
    [Required]
    public int Revision { get; set; }

    /// <summary>The configuration as a JSON object. Read <c>characterStatTabsDefinition</c> to understand a sheet's stats.</summary>
    [Required]
    public object Config { get; set; } = default!;
}
