using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>Error body of the player API: a stable code to branch on and a message for people.</summary>
public class ExternalApiErrorDto
{
    /// <summary>Stable, machine-readable code such as <c>revision_conflict</c>; see <c>ExternalApiErrors</c>.</summary>
    [Required]
    public string Error { get; set; } = default!;

    [Required]
    public string Message { get; set; } = default!;

    /// <summary>With <c>revision_conflict</c>: the revision the sheet is at now.</summary>
    [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
    public int? CurrentRevision { get; set; }

    /// <summary>With <c>invalid_request</c> and <c>invalid_sheet</c>: what exactly is wrong.</summary>
    [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
    public List<string>? Problems { get; set; }
}

/// <summary>The <c>error</c> codes of the player API.</summary>
public static class ExternalApiErrors
{
    /// <summary>The thing does not exist, or the key's owner may not see it.</summary>
    public const string NotFound = "not_found";

    /// <summary>The request body or a parameter is not valid; <c>problems</c> lists why.</summary>
    public const string InvalidRequest = "invalid_request";

    /// <summary>The owner may see it but not change it (e.g. someone else's note).</summary>
    public const string Forbidden = "forbidden";

    /// <summary>The sheet changed since <c>fromRevision</c>; reload and apply the change again.</summary>
    public const string RevisionConflict = "revision_conflict";

    /// <summary>The JSON Patch is malformed or does not apply to the sheet (e.g. a path that is not there).</summary>
    public const string InvalidPatch = "invalid_patch";

    /// <summary>The patched sheet would break the character in Questkeeper; <c>problems</c> lists why.</summary>
    public const string InvalidSheet = "invalid_sheet";

    /// <summary>The campaign has no open fight, or the fight already ended.</summary>
    public const string NoOpenFight = "no_open_fight";

    /// <summary>The fight changed in a way that conflicts with the request (e.g. a participant already rolled).</summary>
    public const string FightConflict = "fight_conflict";

    /// <summary>Only text blocks can be written through the API.</summary>
    public const string UnsupportedBlockType = "unsupported_block_type";

    /// <summary>The server could not store the change; try again later.</summary>
    public const string WriteFailed = "write_failed";
}
