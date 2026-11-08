using System.ComponentModel.DataAnnotations;
using System.Text.Json;
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
using RPGTableHelper.WebApi.Services.Images;
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
        private readonly IImageUploadService _imageUploadService;

        public ExternalNotesController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            INoteService noteService,
            INoteAccessChangeNotifier noteAccessChangeNotifier,
            IImageUploadService imageUploadService
        )
            : base(queryProcessor, userContext)
        {
            _noteService = noteService;
            _noteAccessChangeNotifier = noteAccessChangeNotifier;
            _imageUploadService = imageUploadService;
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
        /// <response code="409">If the document changed since <c>expectedLastModifiedAt</c></response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
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

            var conflict = VersionConflict(document, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
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

        /// <summary>
        /// Deletes your document with all its blocks. With <c>?expectedLastModifiedAt=</c> only if it did not change
        /// since.
        /// </summary>
        /// <response code="204">Deleted</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        /// <response code="409">If the document changed since <c>expectedLastModifiedAt</c></response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpDelete("documents/{documentId:guid}")]
        public async Task<IActionResult> DeleteDocumentAsync(
            Guid documentId,
            [FromQuery] DateTimeOffset? expectedLastModifiedAt,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var conflict = VersionConflict(document, expectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
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
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
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

            var conflict = VersionConflict(document, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
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
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
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
                    "This is an image block: change it with PUT image-blocks/{id}."
                );
            }

            var conflict = VersionConflict(document!, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
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

        /// <summary>
        /// Adds an image block to your document, sent as <c>multipart/form-data</c>: the file <c>image</c> (PNG or
        /// JPEG, at most 10 MB), the JSON array <c>visibleTo</c> (<c>[]</c> keeps it private) and optionally the
        /// caption <c>markdownText</c>. <c>visibleTo</c> guards the block; anyone with the image's link can load
        /// the image.
        /// </summary>
        /// <response code="201">The new block</response>
        /// <response code="400">If the file is no PNG or JPEG or too big, or <c>visibleTo</c> is not valid</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ExternalNoteBlockDto), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("documents/{documentId:guid}/image-blocks")]
        public async Task<ActionResult<ExternalNoteBlockDto>> CreateImageBlockAsync(
            Guid documentId,
            [FromForm] ExternalImageBlockCreateRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var requestedReaders = ParseVisibleTo(request.VisibleTo);
            if (requestedReaders == null)
            {
                return InvalidRequest(
                    "visibleTo must be a JSON array of user ids.",
                    new List<string> { "visibleTo: not a JSON array of user ids, e.g. [\"40c3...\"] or []." }
                );
            }

            var (visibleTo, invalid) = await ResolveVisibleToAsync(document.CreatedForCampagneId, requestedReaders, cancellationToken)
                .ConfigureAwait(false);
            if (visibleTo == null)
            {
                return invalid!;
            }

            var imageProblem = await _imageUploadService.ValidateAsync(request.Image, cancellationToken).ConfigureAwait(false);
            if (imageProblem != null)
            {
                return InvalidRequest(imageProblem, new List<string> { $"image: {imageProblem}" });
            }

            var image = await _imageUploadService
                .StoreAsync(document.CreatedForCampagneId, CurrentUser, request.Image, cancellationToken)
                .ConfigureAwait(false);
            if (image == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not store the image.");
            }

            var created = await new NoteBlockCreateQuery
            {
                ModelToCreate = new ImageBlock
                {
                    NoteDocumentId = document.Id,
                    CreatingUserId = CurrentUser,
                    ImageMetaDataId = image.MetaDataId,
                    PublicImageUrl = image.PublicUrl,
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
        /// Replaces the caption and the visibility of your image block; the image stays. Send <c>visibleTo</c> every
        /// time: whoever is not in it can no longer read the block.
        /// </summary>
        /// <response code="200">The changed block</response>
        /// <response code="400">If <c>visibleTo</c> names someone who is not in the campaign, or it is a text block</response>
        /// <response code="403">If the block is someone else's</response>
        /// <response code="404">If the block does not exist or is not shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteBlockDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpPut("image-blocks/{blockId:guid}")]
        public async Task<ActionResult<ExternalNoteBlockDto>> UpdateImageBlockAsync(
            Guid blockId,
            [FromBody] [Required] ExternalImageBlockUpdateRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (before, document, denied) = await LoadBlockForWriteAsync(blockId, cancellationToken).ConfigureAwait(false);
            if (before == null)
            {
                return denied!;
            }

            if (before is not ImageBlock imageBlock)
            {
                return Error(
                    StatusCodes.Status400BadRequest,
                    ExternalApiErrors.UnsupportedBlockType,
                    "This is a text block: change it with PUT blocks/{id}."
                );
            }

            var conflict = VersionConflict(document!, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
            }

            var (visibleTo, invalid) = await ResolveVisibleToAsync(document!.CreatedForCampagneId, request.VisibleTo, cancellationToken)
                .ConfigureAwait(false);
            if (visibleTo == null)
            {
                return invalid!;
            }

            var updated = await new NoteBlockUpdateQuery
            {
                UpdatedModel = new ImageBlock
                {
                    Id = imageBlock.Id,
                    NoteDocumentId = imageBlock.NoteDocumentId,
                    CreatingUserId = imageBlock.CreatingUserId,
                    CreationDate = imageBlock.CreationDate,
                    ImageMetaDataId = imageBlock.ImageMetaDataId,
                    PublicImageUrl = imageBlock.PublicImageUrl,
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

        /// <summary>
        /// Deletes your block (text or image). With <c>?expectedLastModifiedAt=</c> (of the document) only if the
        /// document did not change since.
        /// </summary>
        /// <response code="204">Deleted</response>
        /// <response code="403">If the block is someone else's</response>
        /// <response code="404">If the block does not exist or is not shared with you</response>
        /// <response code="409">If the document changed since <c>expectedLastModifiedAt</c></response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpDelete("blocks/{blockId:guid}")]
        public async Task<IActionResult> DeleteBlockAsync(
            Guid blockId,
            [FromQuery] DateTimeOffset? expectedLastModifiedAt,
            CancellationToken cancellationToken
        )
        {
            var (block, document, denied) = await LoadBlockForWriteAsync(blockId, cancellationToken).ConfigureAwait(false);
            if (block == null)
            {
                return denied!;
            }

            var conflict = VersionConflict(document!, expectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
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
        /// Adds several text blocks to the end of your document in one request (one write for the rate limit). Each
        /// block needs its own <c>visibleTo</c>; <c>[]</c> keeps it private. Nothing is saved if one of them is not
        /// valid.
        /// </summary>
        /// <response code="201">The new blocks, in order</response>
        /// <response code="400">If a <c>visibleTo</c> names someone who is not in the campaign</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        /// <response code="409">If the document changed since <c>expectedLastModifiedAt</c></response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(List<ExternalNoteBlockDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpPost("documents/{documentId:guid}/blocks/batch")]
        public async Task<ActionResult<List<ExternalNoteBlockDto>>> CreateTextBlocksAsync(
            Guid documentId,
            [FromBody] [Required] ExternalTextBlockBatchRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var conflict = VersionConflict(document, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
            }

            var members = await LoadCampaignMemberIdsAsync(document.CreatedForCampagneId, cancellationToken).ConfigureAwait(false);
            var readersPerBlock = new List<List<User.UserIdentifier>>();
            var problems = new List<string>();
            for (var index = 0; index < request.Blocks.Count; index++)
            {
                var (readers, blockProblems) = ResolveVisibleTo(members, request.Blocks[index].VisibleTo, $"blocks[{index}].visibleTo");
                readersPerBlock.Add(readers);
                problems.AddRange(blockProblems);
            }

            if (problems.Count > 0)
            {
                return InvalidRequest("visibleTo may only name members of the campaign (see GET campaigns/{id}/members).", problems);
            }

            var createdBlocks = new List<ExternalNoteBlockDto>();
            for (var index = 0; index < request.Blocks.Count; index++)
            {
                var created = await new NoteBlockCreateQuery
                {
                    ModelToCreate = new TextBlock
                    {
                        NoteDocumentId = document.Id,
                        CreatingUserId = CurrentUser,
                        MarkdownText = request.Blocks[index].MarkdownText,
                        PermittedUsers = readersPerBlock[index],
                    },
                }
                    .RunAsync(QueryProcessor, cancellationToken)
                    .ConfigureAwait(false);
                var block = created.IsSome
                    ? await LoadBlockAsync(created.Get().Value, cancellationToken).ConfigureAwait(false)
                    : null;
                if (block == null)
                {
                    return Error(
                        StatusCodes.Status500InternalServerError,
                        ExternalApiErrors.WriteFailed,
                        $"Could not create block {index}; the {index} blocks before it were saved."
                    );
                }

                await _noteAccessChangeNotifier
                    .NotifyBlockCreatedAsync(document.CreatedForCampagneId, document.Id, block, CurrentUser, cancellationToken)
                    .ConfigureAwait(false);
                createdBlocks.Add(ToDto(block));
            }

            return Created($"/{ExternalApiRoutes.V1}/documents/{document.Id.Value}", createdBlocks);
        }

        /// <summary>
        /// Puts the blocks of your document into a new order. List every block of the document you can read, in the
        /// new order. You may add your blocks from other documents of yours in the same campaign: they move here.
        /// Moving and ordering never change a block: it keeps its id, content, image and who may read it.
        /// </summary>
        /// <response code="200">The document in its new order</response>
        /// <response code="400">If a block of the document is missing, listed twice, or not yours to move here</response>
        /// <response code="403">If the document is someone else's</response>
        /// <response code="404">If the document does not exist or nothing in it is shared with you</response>
        /// <response code="409">If the document changed since <c>expectedLastModifiedAt</c></response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(ExternalNoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [HttpPut("documents/{documentId:guid}/block-order")]
        public async Task<ActionResult<ExternalNoteDocumentDto>> ArrangeBlocksAsync(
            Guid documentId,
            [FromBody] [Required] ExternalBlockOrderRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
            if (document == null)
            {
                return denied!;
            }

            var conflict = VersionConflict(document, request.ExpectedLastModifiedAt);
            if (conflict != null)
            {
                return conflict;
            }

            var problems = request
                .BlockIds.GroupBy(id => id)
                .Where(group => group.Count() > 1)
                .Select(group => $"blockIds: {group.Key} is listed more than once.")
                .ToList();

            var inDocument = document
                .NoteBlocks.Where(b => !b.IsDeleted)
                .OrderBy(b => b.SortIndex ?? -1)
                .ThenBy(b => b.CreationDate)
                .ToList();
            var readable = inDocument.Where(IsReadableByCaller).Select(b => b.Id.Value).ToHashSet();
            problems.AddRange(
                readable
                    .Where(id => !request.BlockIds.Contains(id))
                    .Select(id => $"blockIds: {id} is in the document but not listed. List every block; delete blocks with DELETE blocks/{{id}}.")
            );

            var moving = new List<(NoteBlockModelBase Block, NoteDocument Source)>();
            var inDocumentIds = inDocument.Select(b => b.Id.Value).ToHashSet();
            foreach (var blockId in request.BlockIds.Distinct().Where(id => !inDocumentIds.Contains(id)))
            {
                var block = await LoadBlockAsync(blockId, cancellationToken).ConfigureAwait(false);
                var source = block == null || block.CreatingUserId.Value != CurrentUserId
                    ? null
                    : await LoadOwnDocumentAsync(block.NoteDocumentId.Value, cancellationToken).ConfigureAwait(false);
                if (block == null || source == null)
                {
                    problems.Add($"blockIds: {blockId} is not one of your blocks in one of your documents.");
                }
                else if (source.CreatedForCampagneId != document.CreatedForCampagneId)
                {
                    problems.Add($"blockIds: {blockId} is in a document of another campaign.");
                }
                else
                {
                    moving.Add((block, source));
                }
            }

            if (problems.Count > 0)
            {
                return InvalidRequest("The block order does not fit the document.", problems);
            }

            // Blocks the caller cannot read stay in the document, after the listed ones, in their current order.
            var order = request
                .BlockIds.Concat(inDocument.Where(b => !readable.Contains(b.Id.Value)).Select(b => b.Id.Value))
                .Select(NoteBlockModelBase.NoteBlockModelBaseIdentifier.From)
                .ToList();
            var arranged = await new NoteBlocksArrangeQuery { DocumentId = document.Id, OrderedBlockIds = order }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var reloaded = arranged.IsSome
                ? await LoadOwnDocumentAsync(documentId, cancellationToken).ConfigureAwait(false)
                : null;
            if (reloaded == null)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not arrange the blocks.");
            }

            foreach (var (block, source) in moving)
            {
                await _noteAccessChangeNotifier
                    .NotifyBlockDeletedAsync(source.CreatedForCampagneId, source.Id, block, CurrentUser, cancellationToken)
                    .ConfigureAwait(false);
                await _noteAccessChangeNotifier
                    .NotifyBlockCreatedAsync(reloaded.CreatedForCampagneId, reloaded.Id, block, CurrentUser, cancellationToken)
                    .ConfigureAwait(false);
            }

            await _noteAccessChangeNotifier
                .NotifyDocumentUpdatedAsync(reloaded, CurrentUser, cancellationToken)
                .ConfigureAwait(false);
            return Ok(ToDto(reloaded));
        }

        /// <summary>
        /// Moves several of your documents into one folder (<c>groupName</c>) in one request, e.g. to rename or
        /// dissolve a folder. Their content does not change. Nothing is moved if one of them is not yours.
        /// </summary>
        /// <response code="200">The moved documents</response>
        /// <response code="400">If a document belongs to another campaign</response>
        /// <response code="403">If a document is someone else's</response>
        /// <response code="404">If the campaign or a document does not exist or is not shared with you</response>
        [RequireScope(ApiKeyScopes.NotesWrite)]
        [ProducesResponseType(typeof(List<ExternalNoteDocumentDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpPost("campaigns/{campaignId:guid}/documents/move")]
        public async Task<ActionResult<List<ExternalNoteDocumentDto>>> MoveDocumentsAsync(
            Guid campaignId,
            [FromBody] [Required] ExternalDocumentsMoveRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var campaign = await LoadCampaignAsMemberAsync(campaignId, cancellationToken).ConfigureAwait(false);
            if (campaign == null)
            {
                return NotFoundError("Campaign not found.");
            }

            var groupName = request.GroupName.Trim();
            if (groupName.Length == 0)
            {
                return InvalidRequest("groupName must not be empty.", new List<string> { "groupName: empty." });
            }

            var documents = new List<NoteDocument>();
            foreach (var documentId in request.DocumentIds.Distinct())
            {
                var (document, denied) = await LoadDocumentForWriteAsync(documentId, cancellationToken).ConfigureAwait(false);
                if (document == null)
                {
                    return denied!;
                }

                if (document.CreatedForCampagneId.Value != campaignId)
                {
                    return InvalidRequest(
                        "Every document must belong to the campaign.",
                        new List<string> { $"documentIds: {documentId} belongs to another campaign." }
                    );
                }

                documents.Add(document);
            }

            var moved = await new NoteDocumentsSetGroupQuery
            {
                DocumentIds = documents.Select(d => d.Id).ToList(),
                GroupName = groupName,
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (moved.IsNone)
            {
                return Error(StatusCodes.Status500InternalServerError, ExternalApiErrors.WriteFailed, "Could not move the documents.");
            }

            var result = new List<ExternalNoteDocumentDto>();
            foreach (var document in documents)
            {
                var reloaded = await LoadOwnDocumentAsync(document.Id.Value, cancellationToken).ConfigureAwait(false);
                if (reloaded == null)
                {
                    continue;
                }

                await _noteAccessChangeNotifier
                    .NotifyDocumentUpdatedAsync(reloaded, CurrentUser, cancellationToken)
                    .ConfigureAwait(false);
                result.Add(ToDto(reloaded));
            }

            return Ok(result);
        }

        /// <summary>The user ids in a form field, or null if it is not a JSON array of them.</summary>
        private static List<Guid>? ParseVisibleTo(string visibleTo)
        {
            try
            {
                return JsonSerializer.Deserialize<List<Guid>>(visibleTo);
            }
            catch (JsonException)
            {
                return null;
            }
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
            var members = await LoadCampaignMemberIdsAsync(campaignId, cancellationToken).ConfigureAwait(false);
            var (readers, problems) = ResolveVisibleTo(members, requested, "visibleTo");
            return problems.Count > 0
                ? (null, InvalidRequest("visibleTo may only name members of the campaign (see GET campaigns/{id}/members).", problems))
                : (readers, null);
        }

        /// <summary>The DM and every player with a character in the campaign.</summary>
        private async Task<HashSet<Guid>> LoadCampaignMemberIdsAsync(
            Campagne.CampagneIdentifier campaignId,
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

            return members;
        }

        /// <summary>The readers without the caller, and a problem for everyone who is not a member.</summary>
        private (List<User.UserIdentifier> Readers, List<string> Problems) ResolveVisibleTo(
            HashSet<Guid> members,
            IEnumerable<Guid> requested,
            string field
        )
        {
            var readers = requested.Distinct().Where(id => id != CurrentUserId).ToList();
            var problems = readers
                .Where(id => !members.Contains(id))
                .Select(id => $"{field}: {id} is not a member of the campaign.")
                .ToList();
            return (readers.Select(DataLayer.Contracts.Models.Auth.User.UserIdentifier.From).ToList(), problems);
        }

        /// <summary>
        /// A 409 if the document changed since <paramref name="expected"/>, else null. Compared to the millisecond, as
        /// clients that parse the timestamp keep no more.
        /// </summary>
        private ObjectResult? VersionConflict(NoteDocument document, DateTimeOffset? expected)
        {
            if (expected == null || (document.LastModifiedAt - expected.Value).Duration() < TimeSpan.FromMilliseconds(1))
            {
                return null;
            }

            return StatusCode(
                StatusCodes.Status409Conflict,
                new ExternalApiErrorDto
                {
                    Error = ExternalApiErrors.VersionConflict,
                    Message = "The document changed since expectedLastModifiedAt; nothing was saved. Read it again.",
                    CurrentLastModifiedAt = document.LastModifiedAt,
                }
            );
        }

        private bool IsReadableByCaller(NoteBlockModelBase block) =>
            block.CreatingUserId.Value == CurrentUserId || block.PermittedUsers.Any(u => u.Value == CurrentUserId);

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
                    .Where(IsReadableByCaller)
                    .OrderBy(b => b.SortIndex ?? -1)
                    .ThenBy(b => b.CreationDate)
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
                ImageUrl = block is ImageBlock imageBlock ? ToFullImageUrl(imageBlock.PublicImageUrl) : null,
                CreatedByUserId = block.CreatingUserId.Value,
                IsOwn = isOwn,
                VisibleTo = isOwn ? block.PermittedUsers.Select(u => u.Value).ToList() : null,
                CreatedAt = block.CreationDate,
                LastModifiedAt = block.LastModifiedAt,
            };
        }
    }
}
