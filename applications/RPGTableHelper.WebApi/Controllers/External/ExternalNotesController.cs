using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Services;
using RPGTableHelper.WebApi.Services.Auth;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Notes, as in the Questkeeper app: a document holds blocks, and each block says who besides its author may
    /// read it. You read your own documents and every block shared with you; you write only your own.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.V1)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalNotesController : ExternalApiControllerBase
    {
        private readonly INoteService _noteService;
        private readonly INoteAccessChangeNotifier _noteAccessChangeNotifier;

        public ExternalNotesController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            INoteService noteService,
            INoteAccessChangeNotifier noteAccessChangeNotifier
        )
            : base(queryProcessor, userContext)
        {
            _noteService = noteService;
            _noteAccessChangeNotifier = noteAccessChangeNotifier;
        }

        private User.UserIdentifier CurrentUser => UserContext.User.UserIdentifier;

        /// <summary>Your documents in the campaign, and the documents with blocks shared with you.</summary>
        /// <response code="200">The documents, each with the blocks you may read</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.NotesRead)]
        [ProducesResponseType(typeof(List<ExternalNoteDocumentDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("campaigns/{campaignId:guid}/documents")]
        public async Task<ActionResult<List<ExternalNoteDocumentDto>>> GetDocumentsAsync(
            Guid campaignId,
            CancellationToken cancellationToken
        )
        {
            var documents = await _noteService
                .GetNoteDocumentsForUserAsync(campaignId, CurrentUserId, cancellationToken)
                .ConfigureAwait(false);
            if (documents.IsNone)
            {
                return NotFoundError("Campaign not found.");
            }

            return Ok(documents.Get().Where(d => !d.IsDeleted).Select(ToDto).ToList());
        }

        /// <summary>One document with the blocks you may read.</summary>
        /// <response code="200">The document</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        [RequireScope(ApiKeyScopes.NotesRead)]
        [ProducesResponseType(typeof(ExternalNoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("documents/{documentId:guid}")]
        public async Task<ActionResult<ExternalNoteDocumentDto>> GetDocumentAsync(
            Guid documentId,
            CancellationToken cancellationToken
        )
        {
            var document = await LoadReadableDocumentAsync(documentId, cancellationToken).ConfigureAwait(false);
            return document == null ? NotFoundError("Document not found.") : Ok(ToDto(document));
        }

        /// <summary>Creates an empty document; add text blocks to it next.</summary>
        /// <response code="201">The new document</response>
        /// <response code="404">If the campaign does not exist or you are not part of it</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteDocumentDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("campaigns/{campaignId:guid}/documents")]
        public async Task<ActionResult<ExternalNoteDocumentDto>> CreateDocumentAsync(
            Guid campaignId,
            [FromBody] [Required] ExternalNoteDocumentRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("Campaign not found.");
            }

            var created = await new NoteDocumentCreateQuery
            {
                ModelToCreate = new NoteDocument
                {
                    Title = request.Title.Trim(),
                    GroupName = request.GroupName.Trim(),
                    CreatingUserId = CurrentUser,
                    CreatedForCampagneId = campaign.Id,
                },
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var document = created.IsSome
                ? await LoadOwnDocumentAsync(created.Get().Value, cancellationToken).ConfigureAwait(false)
                : null;
            if (document == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not create the document.");
            }

            return Created($"/{ExternalApiRoutes.V1}/documents/{document.Id.Value}", ToDto(document));
        }

        /// <summary>Renames your document or moves it to another folder (<c>groupName</c>).</summary>
        /// <response code="200">The changed document</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPut("documents/{documentId:guid}")]
        public async Task<ActionResult<ExternalNoteDocumentDto>> UpdateDocumentAsync(
            Guid documentId,
            [FromBody] [Required] ExternalNoteDocumentRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            document.Title = request.Title.Trim();
            document.GroupName = request.GroupName.Trim();
            var updated = await new NoteDocumentUpdateQuery { UpdatedModel = document }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var reloaded = updated.IsSome
                ? await LoadOwnDocumentAsync(documentId, cancellationToken).ConfigureAwait(false)
                : null;
            if (reloaded == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not change the document.");
            }

            await _noteAccessChangeNotifier
                .NotifyDocumentUpdatedAsync(reloaded, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return Ok(ToDto(reloaded));
        }

        /// <summary>Deletes your document with all its blocks.</summary>
        /// <response code="204">Deleted</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpDelete("documents/{documentId:guid}")]
        public async Task<IActionResult> DeleteDocumentAsync(Guid documentId, CancellationToken cancellationToken)
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var deleted = await new NoteDocumentDeleteQuery { Id = document.Id }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (deleted.IsNone)
            {
                return NotFoundError("Document not found.");
            }

            await _noteAccessChangeNotifier
                .NotifyDocumentDeletedAsync(document, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return NoContent();
        }

        /// <summary>
        /// Adds a text block to your document. <c>visibleTo</c> is required: the campaign members who may read the
        /// block besides you, or <c>[]</c> to keep it private.
        /// </summary>
        /// <response code="201">The new block</response>
        /// <response code="400">If <c>visibleTo</c> names someone who is not in the campaign</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteBlockDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("documents/{documentId:guid}/blocks")]
        public async Task<ActionResult<ExternalNoteBlockDto>> CreateTextBlockAsync(
            Guid documentId,
            [FromBody] [Required] ExternalTextBlockRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var (visibleTo, invalid) = await ResolveVisibleToAsync(document.CreatedForCampagneId, request.VisibleTo, cancellationToken)
                .ConfigureAwait(false);
            if (visibleTo == null)
            {
                return invalid!;
            }

            var created = await new NoteBlockCreateQuery
            {
                ModelToCreate = new TextBlock
                {
                    NoteDocumentId = document.Id,
                    CreatingUserId = CurrentUser,
                    MarkdownText = request.MarkdownText,
                    PermittedUsers = visibleTo,
                },
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var block = created.IsSome
                ? await LoadBlockAsync(created.Get().Value, cancellationToken).ConfigureAwait(false)
                : null;
            if (block == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not create the block.");
            }

            await _noteAccessChangeNotifier
                .NotifyBlockCreatedAsync(document.CreatedForCampagneId, document.Id, block, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return Created($"/{ExternalApiRoutes.V1}/documents/{document.Id.Value}", ToDto(block));
        }

        /// <summary>
        /// Replaces the text and the visibility of your text block. Send <c>visibleTo</c> every time: whoever is
        /// not in it can no longer read the block.
        /// </summary>
        /// <response code="200">The changed block</response>
        /// <response code="400">If <c>visibleTo</c> names someone who is not in the campaign, or it is an image block</response>
        /// <response code="403">If the block is someone else's</response>
        /// <response code="404">If the block does not exist or is not shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteBlockDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPut("blocks/{blockId:guid}")]
        public async Task<ActionResult<ExternalNoteBlockDto>> UpdateTextBlockAsync(
            Guid blockId,
            [FromBody] [Required] ExternalTextBlockRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (before, document, denied) = await LoadBlockForWriteAsync(blockId, cancellationToken).ConfigureAwait(false);
            if (before == null)
            {
                return denied!;
            }

            if (before is not TextBlock textBlock)
            {
                return Error(
                    StatusCodes.Status400BadRequest,
                    ExternalApiErrors.UnsupportedBlockType,
                    "Only text blocks can be changed through the API."
                );
            }

            var (visibleTo, invalid) = await ResolveVisibleToAsync(document!.CreatedForCampagneId, request.VisibleTo, cancellationToken)
                .ConfigureAwait(false);
            if (visibleTo == null)
            {
                return invalid!;
            }

            var updated = await new NoteBlockUpdateQuery
            {
                UpdatedModel = new TextBlock
                {
                    Id = textBlock.Id,
                    NoteDocumentId = textBlock.NoteDocumentId,
                    CreatingUserId = textBlock.CreatingUserId,
                    CreationDate = textBlock.CreationDate,
                    MarkdownText = request.MarkdownText,
                    PermittedUsers = visibleTo,
                },
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var after = updated.IsSome ? await LoadBlockAsync(blockId, cancellationToken).ConfigureAwait(false) : null;
            if (after == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not change the block.");
            }

            await _noteAccessChangeNotifier
                .NotifyBlockUpdatedAsync(document.CreatedForCampagneId, document.Id, before, after, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return Ok(ToDto(after));
        }

        /// <summary>Deletes your block (text or image).</summary>
        /// <response code="204">Deleted</response>
        /// <response code="403">If the block is someone else's</response>
        /// <response code="404">If the block does not exist or is not shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpDelete("blocks/{blockId:guid}")]
        public async Task<IActionResult> DeleteBlockAsync(Guid blockId, CancellationToken cancellationToken)
        {
            var (block, document, denied) = await LoadBlockForWriteAsync(blockId, cancellationToken).ConfigureAwait(false);
            if (block == null)
            {
                return denied!;
            }

            var deleted = await new NoteBlockDeleteQuery { Id = block.Id }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (deleted.IsNone)
            {
                return NotFoundError("Block not found.");
            }

            await _noteAccessChangeNotifier
                .NotifyBlockDeletedAsync(document!.CreatedForCampagneId, document.Id, block, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return NoContent();
        }

        /// <summary>
        /// The requested readers as members of the campaign, without the author (who always reads their own
        /// blocks); or a 400 naming who is not a member.
        /// </summary>
        private async Task<(List<User.UserIdentifier>? VisibleTo, ObjectResult? Invalid)> ResolveVisibleToAsync(
            Campagne.CampagneIdentifier campaignId,
            IEnumerable<Guid> requested,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId.Value, cancellationToken).ConfigureAwait(false);
            var characters = await new PlayerCharactersForCampagneQuery { CampagneId = campaignId }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var members = (characters.IsSome ? characters.Get() : new List<PlayerCharacter>())
                .Select(c => c.PlayerUserId.Value)
                .ToHashSet();
            if (campaign != null)
            {
                members.Add(campaign.DmUserId.Value);
            }

            var readers = requested.Distinct().Where(id => id != CurrentUserId).ToList();
            var strangers = readers.Where(id => !members.Contains(id)).ToList();
            if (strangers.Count > 0)
            {
                return (
                    null,
                    InvalidRequest(
                        "visibleTo may only name members of the campaign (see GET campaigns/{id}/members).",
                        strangers.Select(id => $"visibleTo: {id} is not a member of the campaign.").ToList()
                    )
                );
            }

            return (readers.Select(DataLayer.Contracts.Models.Auth.User.UserIdentifier.From).ToList(), null);
        }

        /// <summary>The caller's own document, or why not: 404 if they may not read it, 403 if they only read it.</summary>
        private async Task<(NoteDocument? Document, ObjectResult? Denied)> LoadDocumentForWriteAsync(
            Guid documentId,
            CancellationToken cancellationToken
        )
        {
            var document = await LoadOwnDocumentAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document != null)
            {
                return (document, null);
            }

            return await LoadReadableDocumentAsync(documentId, cancellationToken).ConfigureAwait(false) == null
                ? (null, NotFoundError("Document not found."))
                : (null, Error(StatusCodes.Status403Forbidden, ExternalApiErrors.Forbidden, "Only the author can change this document."));
        }

        private async Task<(NoteBlockModelBase? Block, NoteDocument? Document, ObjectResult? Denied)> LoadBlockForWriteAsync(
            Guid blockId,
            CancellationToken cancellationToken
        )
        {
            var block = await LoadBlockAsync(blockId, cancellationToken).ConfigureAwait(false);
            if (block == null)
            {
                return (null, null, NotFoundError("Block not found."));
            }

            if (block.CreatingUserId.Value != CurrentUserId)
            {
                return block.PermittedUsers.Any(u => u.Value == CurrentUserId)
                    ? (null, null, Error(StatusCodes.Status403Forbidden, ExternalApiErrors.Forbidden, "Only the author can change this block."))
                    : (null, null, NotFoundError("Block not found."));
            }

            var document = await LoadOwnDocumentAsync(block.NoteDocumentId.Value, cancellationToken).ConfigureAwait(false);
            return document == null ? (null, null, NotFoundError("Block not found.")) : (block, document, null);
        }

        private async Task<NoteDocument?> LoadReadableDocumentAsync(Guid documentId, CancellationToken cancellationToken)
        {
            var document = await _noteService
                .GetNoteDocumentByIdAsync(documentId, CurrentUserId, cancellationToken)
                .ConfigureAwait(false);
            return document.IsSome && !document.Get().IsDeleted ? document.Get() : null;
        }

        private async Task<NoteDocument?> LoadOwnDocumentAsync(Guid documentId, CancellationToken cancellationToken)
        {
            var document = await new NoteDocumentQuery { ModelId = NoteDocument.NoteDocumentIdentifier.From(documentId) }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            return document.IsSome && !document.Get().IsDeleted && document.Get().CreatingUserId.Value == CurrentUserId
                ? document.Get()
                : null;
        }

        private async Task<NoteBlockModelBase?> LoadBlockAsync(Guid blockId, CancellationToken cancellationToken)
        {
            var block = await new NoteBlockQuery { ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockId) }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            return block.IsSome && !block.Get().IsDeleted ? block.Get() : null;
        }

        private ExternalNoteDocumentDto ToDto(NoteDocument document) =>
            new()
            {
                Id = document.Id.Value,
                CampaignId = document.CreatedForCampagneId.Value,
                Title = document.Title,
                GroupName = document.GroupName,
                CreatedByUserId = document.CreatingUserId.Value,
                IsOwn = document.CreatingUserId.Value == CurrentUserId,
                CreatedAt = document.CreationDate,
                LastModifiedAt = document.LastModifiedAt,
                Blocks = document
                    .NoteBlocks.Where(b => !b.IsDeleted)
                    .Where(b => b.CreatingUserId.Value == CurrentUserId || b.PermittedUsers.Any(u => u.Value == CurrentUserId))
                    .OrderBy(b => b.CreationDate)
                    .Select(ToDto)
                    .ToList(),
            };

        private ExternalNoteBlockDto ToDto(NoteBlockModelBase block)
        {
            var isOwn = block.CreatingUserId.Value == CurrentUserId;
            return new ExternalNoteBlockDto
            {
                Id = block.Id.Value,
                Type = block is ImageBlock ? "image" : "text",
                MarkdownText = block switch
                {
                    TextBlock text => text.MarkdownText,
                    ImageBlock image => image.MarkdownText,
                    _ => null,
                },
                ImageUrl = (block as ImageBlock)?.PublicImageUrl,
                CreatedByUserId = block.CreatingUserId.Value,
                IsOwn = isOwn,
                VisibleTo = isOwn ? block.PermittedUsers.Select(u => u.Value).ToList() : null,
                CreatedAt = block.CreationDate,
                LastModifiedAt = block.LastModifiedAt,
            };
        }
    }
}
