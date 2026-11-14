using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class NotesController : ControllerBase
    {
        private readonly IQueryProcessor _queryProcessor;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        private readonly INoteService _noteService;
        private readonly INoteAccessChangeNotifier _noteAccessChangeNotifier;

        public NotesController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            IMapper mapper,
            INoteService noteService,
            INoteAccessChangeNotifier noteAccessChangeNotifier
        )
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
            _mapper = mapper;
            _noteService = noteService;
            _noteAccessChangeNotifier = noteAccessChangeNotifier;
        }

        /// <summary>
        /// Returns a list of documents this user can see for a given campagne.
        /// </summary>
        /// <remarks>You must be within the correct campagne</remarks>
        /// <param name="campagneid">The id of the desired campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the document.</returns>
        /// <response code="200">The documents for the user</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(List<NoteDocumentDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getdocuments/{campagneid}")]
        public async Task<ActionResult<List<NoteDocumentDto>>> GetNoteDocumentsForUserAsync(
            string campagneid,
            CancellationToken cancellationToken
        )
        {
            if (campagneid == null)
            {
                return BadRequest("No valid campagneid passed");
            }

            if (!Guid.TryParse(campagneid, out var campagneidparsed))
            {
                return BadRequest("No valid campagneid passed");
            }

            var noteDocuments = await _noteService.GetNoteDocumentsForUserAsync(
                campagneidparsed,
                Guid.Parse(_userContext.User.UserIdentifier.Value.ToString()), // Assuming Value is Guid, or passing IdentityProviderId
                cancellationToken
            );

            if (noteDocuments.IsNone)
            {
                return BadRequest("Could not retrieve info.");
            }

            var mappedDtos = noteDocuments.Get().Select(_mapper.Map<NoteDocumentDto>).ToList();
            return Ok(mappedDtos);
        }

        /// <summary>
        /// Returns a single document.
        /// </summary>
        /// <remarks>You must be within the correct campagne and the document has to be your own or shared with you</remarks>
        /// <param name="notedocumentid">The id of the desired campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the document.</returns>
        /// <response code="200">The document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(NoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getdocument/{notedocumentid}")]
        public async Task<ActionResult<NoteDocumentDto>> GetNoteDocumentByIdAsync(
            string notedocumentid,
            CancellationToken cancellationToken
        )
        {
            if (notedocumentid == null)
            {
                return BadRequest("No valid notedocumentid passed");
            }

            if (!Guid.TryParse(notedocumentid, out var notedocumentidparsed))
            {
                return BadRequest("No valid notedocumentid passed");
            }

            var noteDocument = await _noteService.GetNoteDocumentByIdAsync(
                notedocumentidparsed,
                Guid.Parse(_userContext.User.UserIdentifier.Value.ToString()),
                cancellationToken
            );

            if (noteDocument.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            var mappedDto = _mapper.Map<NoteDocumentDto>(noteDocument.Get());
            return Ok(mappedDto);
        }

        /// <summary>
        /// Deletes a single document.
        /// </summary>
        /// <remarks>You must be within the correct campagne and the document has to be your own</remarks>
        /// <param name="notedocumentid">The id of the desired campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(NoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpDelete("deletedocument/{notedocumentid}")]
        public async Task<IActionResult> DeleteNoteDocumentByIdAsync(
            string notedocumentid,
            CancellationToken cancellationToken
        )
        {
            if (notedocumentid == null)
            {
                return BadRequest("No valid notedocumentid passed");
            }

            if (!Guid.TryParse(notedocumentid, out var notedocumentidparsed))
            {
                return BadRequest("No valid notedocumentid passed");
            }

            var noteDocument = await new NoteDocumentQuery
            {
                ModelId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocument.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != noteDocument.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            var deleteResult = await new NoteDocumentDeleteQuery { Id = noteDocument.Get().Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (deleteResult.IsNone)
            {
                return BadRequest();
            }

            await _noteAccessChangeNotifier
                .NotifyDocumentDeletedAsync(noteDocument.Get(), _userContext.User.UserIdentifier, cancellationToken)
                .ConfigureAwait(false);

            return Ok();
        }

        /// <summary>
        /// Creates a single document.
        /// </summary>
        /// <remarks>You must be within the correct campagne</remarks>
        /// <param name="notedocument">The new document</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(NoteDocument.NoteDocumentIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createdocument")]
        public async Task<ActionResult<NoteDocument.NoteDocumentIdentifier>> CreateNoteDocumentAsync(
            [FromBody] [Required] NoteDocumentDto notedocument,
            CancellationToken cancellationToken
        )
        {
            if (notedocument == null)
            {
                return BadRequest("No valid notedocument passed");
            }

            var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = notedocument.CreatedForCampagneId,
                UserIdToCheck = _userContext.User.UserIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagneResult.IsNone)
            {
                return BadRequest("Could not retrieve info.");
            }

            if (!isUserInCampagneResult.Get())
            {
                return Unauthorized();
            }

            notedocument.CreatingUserId = _userContext.User.UserIdentifier;

            var noteDocumentCreationResult = await new NoteDocumentCreateQuery
            {
                ModelToCreate = _mapper.Map<NoteDocument>(notedocument),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocumentCreationResult.IsNone)
            {
                return BadRequest("Could not create NoteDocument");
            }

            return Ok(noteDocumentCreationResult.Get());
        }

        /// <summary>
        /// Creates a single text block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="textBlockToCreate">The new textblock</param>
        /// <param name="notedocumentid">The document id where this block will be assigned</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <param name="insertBeforeBlockId">Optional: a block of the document the new block goes right before. Without it the new block goes last.</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(TextBlock), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createtextblock/{notedocumentid}")]
        public async Task<ActionResult<TextBlock>> CreateTextBlockForDocumentAsync(
            [FromBody] [Required] TextBlock textBlockToCreate,
            [FromRoute] string notedocumentid,
            CancellationToken cancellationToken,
            [FromQuery] Guid? insertBeforeBlockId = null
        )
        {
            if (notedocumentid == null)
            {
                return BadRequest("No valid notedocumentid passed");
            }

            if (!Guid.TryParse(notedocumentid, out var notedocumentidparsed))
            {
                return BadRequest("No valid notedocumentid passed");
            }

            var noteDocument = await new NoteDocumentQuery
            {
                ModelId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocument.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != noteDocument.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            if (!await IsBlockOfDocumentAsync(insertBeforeBlockId, notedocumentidparsed, cancellationToken).ConfigureAwait(false))
            {
                return BadRequest("insertBeforeBlockId is not a block of this document");
            }

            textBlockToCreate.NoteDocumentId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed);
            textBlockToCreate.CreatingUserId = _userContext.User.UserIdentifier;

            var textBlockCreationResult = await new NoteBlockCreateQuery { ModelToCreate = textBlockToCreate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (textBlockCreationResult.IsNone)
            {
                return BadRequest("Could not create textblock");
            }

            if (insertBeforeBlockId != null)
            {
                await new NoteBlockMoveQuery
                {
                    BlockId = textBlockCreationResult.Get(),
                    BeforeBlockId = Option.From(
                        NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(insertBeforeBlockId.Value)
                    ),
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);
            }

            var textBlock = await new NoteBlockQuery { ModelId = textBlockCreationResult.Get() }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (textBlock.IsNone)
            {
                return BadRequest("Could not load textblock");
            }

            await _noteAccessChangeNotifier
                .NotifyBlockCreatedAsync(
                    noteDocument.Get().CreatedForCampagneId,
                    noteDocument.Get().Id,
                    textBlock.Get(),
                    _userContext.User.UserIdentifier,
                    cancellationToken
                )
                .ConfigureAwait(false);

            return Ok(textBlock.Get());
        }

        /// <summary>
        /// Creates a single image block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="imageBlockToCreate">The new imageblock</param>
        /// <param name="notedocumentid">The document id where this block will be assigned</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <param name="insertBeforeBlockId">Optional: a block of the document the new block goes right before. Without it the new block goes last.</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(ImageBlock), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createimageblock/{notedocumentid}")]
        public async Task<ActionResult<ImageBlock>> CreateImageBlockForDocumentAsync(
            [FromBody] [Required] ImageBlock imageBlockToCreate,
            [FromRoute] string notedocumentid,
            CancellationToken cancellationToken,
            [FromQuery] Guid? insertBeforeBlockId = null
        )
        {
            if (notedocumentid == null)
            {
                return BadRequest("No valid notedocumentid passed");
            }

            if (!Guid.TryParse(notedocumentid, out var notedocumentidparsed))
            {
                return BadRequest("No valid notedocumentid passed");
            }

            var noteDocument = await new NoteDocumentQuery
            {
                ModelId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocument.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != noteDocument.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            if (!await IsBlockOfDocumentAsync(insertBeforeBlockId, notedocumentidparsed, cancellationToken).ConfigureAwait(false))
            {
                return BadRequest("insertBeforeBlockId is not a block of this document");
            }

            imageBlockToCreate.NoteDocumentId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed);
            imageBlockToCreate.CreatingUserId = _userContext.User.UserIdentifier;

            var imageBlockCreationResult = await new NoteBlockCreateQuery { ModelToCreate = imageBlockToCreate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageBlockCreationResult.IsNone)
            {
                return BadRequest("Could not create imageblock");
            }

            if (insertBeforeBlockId != null)
            {
                await new NoteBlockMoveQuery
                {
                    BlockId = imageBlockCreationResult.Get(),
                    BeforeBlockId = Option.From(
                        NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(insertBeforeBlockId.Value)
                    ),
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);
            }

            var imageBlock = await new NoteBlockQuery { ModelId = imageBlockCreationResult.Get() }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageBlock.IsNone)
            {
                return BadRequest("Could not load imageBlock");
            }

            await _noteAccessChangeNotifier
                .NotifyBlockCreatedAsync(
                    noteDocument.Get().CreatedForCampagneId,
                    noteDocument.Get().Id,
                    imageBlock.Get(),
                    _userContext.User.UserIdentifier,
                    cancellationToken
                )
                .ConfigureAwait(false);

            return Ok(imageBlock.Get());
        }

        /// <summary>
        /// Updates a single text block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="textBlockToUpdate">The new textblock</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPut("updatetextblock")]
        public async Task<IActionResult> UpdateTextBlockForDocumentAsync(
            [FromBody] [Required] TextBlock textBlockToUpdate,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery { ModelId = textBlockToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != blockLoaded.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            textBlockToUpdate.CreatingUserId = _userContext.User.UserIdentifier;

            var textBlockUpdateResult = await new NoteBlockUpdateQuery { UpdatedModel = textBlockToUpdate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (textBlockUpdateResult.IsNone)
            {
                return BadRequest("Could not update textblock");
            }

            var updatedTextBlockLoaded = await new NoteBlockQuery { ModelId = textBlockToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            var documentForTextBlockUpdate = await new NoteDocumentQuery
            {
                ModelId = blockLoaded.Get().NoteDocumentId,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (updatedTextBlockLoaded.IsSome && documentForTextBlockUpdate.IsSome)
            {
                await _noteAccessChangeNotifier
                    .NotifyBlockUpdatedAsync(
                        documentForTextBlockUpdate.Get().CreatedForCampagneId,
                        documentForTextBlockUpdate.Get().Id,
                        blockLoaded.Get(),
                        updatedTextBlockLoaded.Get(),
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
            }

            return Ok(textBlockUpdateResult.Get());
        }

        /// <summary>
        /// Updates a single image block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="imageBlockToUpdate">The new imageblock</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPut("updateimageblock")]
        public async Task<IActionResult> UpdateImageBlockForDocumentAsync(
            [FromBody] [Required] ImageBlock imageBlockToUpdate,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery { ModelId = imageBlockToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != blockLoaded.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            imageBlockToUpdate.CreatingUserId = _userContext.User.UserIdentifier;

            var imageBlockUpdateResult = await new NoteBlockUpdateQuery { UpdatedModel = imageBlockToUpdate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageBlockUpdateResult.IsNone)
            {
                return BadRequest("Could not update imageblock");
            }

            var updatedImageBlockLoaded = await new NoteBlockQuery { ModelId = imageBlockToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            var documentForImageBlockUpdate = await new NoteDocumentQuery
            {
                ModelId = blockLoaded.Get().NoteDocumentId,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (updatedImageBlockLoaded.IsSome && documentForImageBlockUpdate.IsSome)
            {
                await _noteAccessChangeNotifier
                    .NotifyBlockUpdatedAsync(
                        documentForImageBlockUpdate.Get().CreatedForCampagneId,
                        documentForImageBlockUpdate.Get().Id,
                        blockLoaded.Get(),
                        updatedImageBlockLoaded.Get(),
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
            }

            return Ok(imageBlockUpdateResult.Get());
        }

        /// <summary>
        /// Updates a document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <remarks>You cannot update text or image blocks through this endpoint</remarks>
        /// <param name="documentToUpdate">The updated document</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPut("updatenote")]
        public async Task<IActionResult> UpdateNoteAsync(
            [FromBody] [Required] NoteDocumentDto documentToUpdate,
            CancellationToken cancellationToken
        )
        {
            var documentLoaded = await new NoteDocumentQuery { ModelId = documentToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (documentLoaded.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != documentLoaded.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            documentToUpdate.CreatingUserId = _userContext.User.UserIdentifier;
            documentToUpdate.IsDeleted = false;
            documentToUpdate.CreatedForCampagneId = documentLoaded.Get().CreatedForCampagneId;

            var documentUpdateResult = await new NoteDocumentUpdateQuery
            {
                UpdatedModel = _mapper.Map<NoteDocument>(documentToUpdate),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (documentUpdateResult.IsNone)
            {
                return BadRequest("Could not update note document");
            }

            var updatedDocumentLoaded = await new NoteDocumentQuery { ModelId = documentToUpdate.Id }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (updatedDocumentLoaded.IsSome)
            {
                await _noteAccessChangeNotifier
                    .NotifyDocumentUpdatedAsync(
                        updatedDocumentLoaded.Get(),
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
            }

            return Ok(documentUpdateResult.Get());
        }

        /// <summary>
        /// Deletes a single note block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="blockToDeleteId">The new textblock</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">Ok if deleted</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpDelete("deleteblock")]
        public async Task<IActionResult> DeleteNoteBlockForDocumentAsync(
            [FromQuery] [Required] NoteBlockModelBase.NoteBlockModelBaseIdentifier blockToDeleteId,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery { ModelId = blockToDeleteId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            if (_userContext.User.UserIdentifier != blockLoaded.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            var documentForBlockDelete = await new NoteDocumentQuery { ModelId = blockLoaded.Get().NoteDocumentId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            var noteBlockDeleteResult = await new NoteBlockDeleteQuery { Id = blockToDeleteId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteBlockDeleteResult.IsNone)
            {
                return BadRequest("Could not delete note block");
            }

            if (documentForBlockDelete.IsSome)
            {
                await _noteAccessChangeNotifier
                    .NotifyBlockDeletedAsync(
                        documentForBlockDelete.Get().CreatedForCampagneId,
                        documentForBlockDelete.Get().Id,
                        blockLoaded.Get(),
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
            }

            return Ok(noteBlockDeleteResult.Get());
        }

        /// <summary>
        /// Moves a block of your document right before another of its blocks, or to the end.
        /// </summary>
        /// <remarks>You must be the owner of the block</remarks>
        /// <param name="blockid">The block to move</param>
        /// <param name="beforeblockid">The block it goes right before; without it the block goes last</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The document in its new order</response>
        /// <response code="400">If the block does not exist or beforeblockid is not another block of its document</response>
        /// <response code="401">If you are not logged in or the block is not yours</response>
        [ProducesResponseType(typeof(NoteDocumentDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPut("moveblock/{blockid}")]
        public async Task<ActionResult<NoteDocumentDto>> MoveNoteBlockAsync(
            [FromRoute] Guid blockid,
            [FromQuery] Guid? beforeblockid,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery
            {
                ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone)
            {
                return BadRequest("Could not retrieve note block");
            }

            if (_userContext.User.UserIdentifier != blockLoaded.Get().CreatingUserId)
            {
                return Unauthorized();
            }

            var moved = await new NoteBlockMoveQuery
            {
                BlockId = blockLoaded.Get().Id,
                BeforeBlockId =
                    beforeblockid == null
                        ? Option.None
                        : Option.From(NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(beforeblockid.Value)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (moved.IsNone)
            {
                return BadRequest("beforeblockid is not another block of this document");
            }

            var documentLoaded = await new NoteDocumentQuery { ModelId = blockLoaded.Get().NoteDocumentId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (documentLoaded.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            await _noteAccessChangeNotifier
                .NotifyDocumentUpdatedAsync(documentLoaded.Get(), _userContext.User.UserIdentifier, cancellationToken)
                .ConfigureAwait(false);

            var ownView = await _noteService
                .GetNoteDocumentByIdAsync(
                    documentLoaded.Get().Id.Value,
                    _userContext.User.UserIdentifier.Value,
                    cancellationToken
                )
                .ConfigureAwait(false);

            if (ownView.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
            }

            return Ok(_mapper.Map<NoteDocumentDto>(ownView.Get()));
        }

        /// <summary>
        /// Adds an image to a text block of your document. The text block becomes an image block with the same
        /// text, position and visibility, under a new id.
        /// </summary>
        /// <remarks>You must be the owner of the block</remarks>
        /// <param name="blockid">The text block</param>
        /// <param name="image">The uploaded or generated image</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The new image block</response>
        /// <response code="400">If the block does not exist or is not a text block</response>
        /// <response code="401">If you are not logged in or the block is not yours</response>
        [ProducesResponseType(typeof(ImageBlock), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("attachimage/{blockid}")]
        public async Task<ActionResult<ImageBlock>> AttachImageToTextBlockAsync(
            [FromRoute] Guid blockid,
            [FromBody] [Required] NoteBlockImageDto image,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery
            {
                ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone || blockLoaded.Get() is not TextBlock textBlock)
            {
                return BadRequest("Could not retrieve text block");
            }

            if (_userContext.User.UserIdentifier != textBlock.CreatingUserId)
            {
                return Unauthorized();
            }

            var replaced = await ReplaceBlockAsync(
                    textBlock,
                    new ImageBlock
                    {
                        MarkdownText = textBlock.MarkdownText,
                        ImageMetaDataId = image.ImageMetaDataId,
                        PublicImageUrl = image.PublicImageUrl,
                    },
                    cancellationToken
                )
                .ConfigureAwait(false);

            if (replaced is not ImageBlock imageBlock)
            {
                return BadRequest("Could not add the image");
            }

            return Ok(imageBlock);
        }

        /// <summary>
        /// Removes the image of an image block of your document. The image block becomes a text block with the same
        /// text, position and visibility, under a new id.
        /// </summary>
        /// <remarks>You must be the owner of the block</remarks>
        /// <param name="blockid">The image block</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The new text block</response>
        /// <response code="400">If the block does not exist or is not an image block</response>
        /// <response code="401">If you are not logged in or the block is not yours</response>
        [ProducesResponseType(typeof(TextBlock), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("removeimage/{blockid}")]
        public async Task<ActionResult<TextBlock>> RemoveImageFromImageBlockAsync(
            [FromRoute] Guid blockid,
            CancellationToken cancellationToken
        )
        {
            var blockLoaded = await new NoteBlockQuery
            {
                ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (blockLoaded.IsNone || blockLoaded.Get() is not ImageBlock imageBlock)
            {
                return BadRequest("Could not retrieve image block");
            }

            if (_userContext.User.UserIdentifier != imageBlock.CreatingUserId)
            {
                return Unauthorized();
            }

            var replaced = await ReplaceBlockAsync(
                    imageBlock,
                    new TextBlock { MarkdownText = imageBlock.MarkdownText ?? string.Empty },
                    cancellationToken
                )
                .ConfigureAwait(false);

            if (replaced is not TextBlock textBlock)
            {
                return BadRequest("Could not remove the image");
            }

            return Ok(textBlock);
        }

        private async Task<NoteBlockModelBase?> ReplaceBlockAsync(
            NoteBlockModelBase oldBlock,
            NoteBlockModelBase replacement,
            CancellationToken cancellationToken
        )
        {
            var newId = await new NoteBlockReplaceQuery { BlockId = oldBlock.Id, Replacement = replacement }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (newId.IsNone)
            {
                return null;
            }

            var newBlock = await new NoteBlockQuery { ModelId = newId.Get() }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);
            var document = await new NoteDocumentQuery { ModelId = oldBlock.NoteDocumentId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (newBlock.IsNone)
            {
                return null;
            }

            if (document.IsSome)
            {
                await _noteAccessChangeNotifier
                    .NotifyBlockDeletedAsync(
                        document.Get().CreatedForCampagneId,
                        document.Get().Id,
                        oldBlock,
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
                await _noteAccessChangeNotifier
                    .NotifyBlockCreatedAsync(
                        document.Get().CreatedForCampagneId,
                        document.Get().Id,
                        newBlock.Get(),
                        _userContext.User.UserIdentifier,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
            }

            return newBlock.Get();
        }

        /// <summary>True if no block is given, or the block is a (not deleted) block of the document.</summary>
        private async Task<bool> IsBlockOfDocumentAsync(Guid? blockId, Guid documentId, CancellationToken cancellationToken)
        {
            if (blockId == null)
            {
                return true;
            }

            var block = await new NoteBlockQuery
            {
                ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockId.Value),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);
            return block.IsSome && block.Get().NoteDocumentId.Value == documentId;
        }
    }
}
