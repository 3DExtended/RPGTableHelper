using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>A note document with the blocks the key's owner may read.</summary>
public class ExternalNoteDocumentDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    public Guid CampaignId { get; set; }

    [Required]
    public string Title { get; set; } = default!;

    /// <summary>The folder the app shows the document in.</summary>
    [Required]
    public string GroupName { get; set; } = default!;

    [Required]
    public Guid CreatedByUserId { get; set; }

    /// <summary>True if the key's owner wrote it and so may change it.</summary>
    [Required]
    public bool IsOwn { get; set; }

    [Required]
    public DateTimeOffset CreatedAt { get; set; }

    [Required]
    public DateTimeOffset LastModifiedAt { get; set; }

    /// <summary>Oldest first. Someone else's document only shows the blocks shared with you.</summary>
    [Required]
    public List<ExternalNoteBlockDto> Blocks { get; set; } = new();
}

public class ExternalNoteBlockDto
{
    [Required]
    public Guid Id { get; set; }

    /// <summary><c>text</c> or <c>image</c>.</summary>
    [Required]
    public string Type { get; set; } = default!;

    /// <summary>Markdown of a text block, or the caption of an image block.</summary>
    public string? MarkdownText { get; set; }

    /// <summary>Only for image blocks: the full URL of the image. Anyone with this link can load the image.</summary>
    public string? ImageUrl { get; set; }

    [Required]
    public Guid CreatedByUserId { get; set; }

    [Required]
    public bool IsOwn { get; set; }

    /// <summary>
    /// Who besides the author may read the block (user ids, see campaign members). Only on your own blocks;
    /// null on blocks someone shared with you.
    /// </summary>
    public List<Guid>? VisibleTo { get; set; }

    [Required]
    public DateTimeOffset CreatedAt { get; set; }

    [Required]
    public DateTimeOffset LastModifiedAt { get; set; }
}

public class ExternalNoteDocumentRequestDto
{
    [Required(AllowEmptyStrings = false)]
    public string Title { get; set; } = default!;

    /// <summary>The folder in the app; any name, documents with the same name are shown together.</summary>
    [Required(AllowEmptyStrings = false)]
    public string GroupName { get; set; } = default!;
}

/// <summary>Content and visibility of a text block. Both are required on create and on update.</summary>
public class ExternalTextBlockRequestDto
{
    [Required(AllowEmptyStrings = true)]
    public string MarkdownText { get; set; } = default!;

    /// <summary>
    /// Who besides you may read the block: user ids of campaign members. <c>[]</c> keeps it private.
    /// Required, so a block is never shared by accident.
    /// </summary>
    [Required]
    public List<Guid> VisibleTo { get; set; } = default!;
}

/// <summary>A new image block, sent as <c>multipart/form-data</c>.</summary>
public class ExternalImageBlockCreateRequestDto
{
    /// <summary>The image: PNG or JPEG, at most 10 MB.</summary>
    [Required]
    public IFormFile Image { get; set; } = default!;

    /// <summary>The caption, as Markdown.</summary>
    public string? MarkdownText { get; set; }

    /// <summary>
    /// Who besides you may read the block: a JSON array of user ids of campaign members. <c>[]</c> keeps it
    /// private. Required, so a block is never shared by accident.
    /// </summary>
    [Required(AllowEmptyStrings = false)]
    public string VisibleTo { get; set; } = default!;
}

/// <summary>Caption and visibility of an image block. The image itself stays.</summary>
public class ExternalImageBlockUpdateRequestDto
{
    /// <summary>The caption, as Markdown. Leaving it out removes the caption.</summary>
    public string? MarkdownText { get; set; }

    /// <summary>Who besides you may read the block. <c>[]</c> keeps it private. Required.</summary>
    [Required]
    public List<Guid> VisibleTo { get; set; } = default!;
}
