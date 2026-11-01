using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>A character's full sheet, exactly as the Questkeeper app stores it.</summary>
public class ExternalCharacterSheetDto
{
    [Required]
    public Guid CharacterId { get; set; }

    public Guid? CampaignId { get; set; }

    [Required]
    public string Name { get; set; } = default!;

    /// <summary>Send this as <c>fromRevision</c> when you change the sheet.</summary>
    [Required]
    public int Revision { get; set; }

    /// <summary>The sheet as a JSON object (stats, inventory, money, companions, ...).</summary>
    [Required]
    public object Sheet { get; set; } = default!;
}

/// <summary>A change to a sheet as an RFC 6902 JSON Patch, applied only if the sheet is still at <c>fromRevision</c>.</summary>
public class ExternalCharacterSheetPatchRequestDto
{
    /// <summary>The revision your change is based on. If the sheet moved on, you get 409 <c>revision_conflict</c>.</summary>
    [Required]
    public int? FromRevision { get; set; }

    /// <summary>The operations, applied in order and all or nothing.</summary>
    [Required]
    [MinLength(1)]
    public List<ExternalJsonPatchOperationDto> Patch { get; set; } = default!;
}

/// <summary>One RFC 6902 operation, e.g. <c>{ "op": "replace", "path": "/characterStats/3/serializedValue", "value": "..." }</c>.</summary>
public class ExternalJsonPatchOperationDto
{
    /// <summary>add, remove, replace, move, copy or test.</summary>
    [Required]
    public string Op { get; set; } = default!;

    /// <summary>JSON Pointer into the sheet.</summary>
    [Required]
    public string Path { get; set; } = default!;

    /// <summary>Source pointer for move and copy.</summary>
    public string? From { get; set; }

    /// <summary>The value for add, replace and test.</summary>
    public object? Value { get; set; }
}

public class ExternalCharacterSheetWriteResultDto
{
    /// <summary>The sheet's revision after your change.</summary>
    [Required]
    public int Revision { get; set; }
}

/// <summary>The new value of one stat, e.g. <c>{ "value": { "value": 17, "maxValue": 30 } }</c> for hit points.</summary>
public class ExternalStatValueRequestDto
{
    /// <summary>
    /// Optional. With it the write fails with 409 if the sheet changed since; without it the stat is simply
    /// overwritten (fine for values only you change, like your hit points).
    /// </summary>
    public int? FromRevision { get; set; }

    /// <summary>The stat's value object, in the shape its value type defines (the decoded <c>serializedValue</c>).</summary>
    [Required]
    public object Value { get; set; } = default!;
}
