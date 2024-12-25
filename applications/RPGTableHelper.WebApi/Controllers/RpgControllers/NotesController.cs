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

        public NotesController(IQueryProcessor queryProcessor, IUserContext userContext, IMapper mapper)
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
            _mapper = mapper;
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

            // check if user is allowed to see document
            var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = Campagne.CampagneIdentifier.From(campagneidparsed),
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

            var noteDocuments = await new NoteDocumentsForUserAndCampagneQuery
            {
                CampagneId = Campagne.CampagneIdentifier.From(campagneidparsed),
                UserId = _userContext.User.UserIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocuments.IsNone)
            {
                return BadRequest("Could not retrieve NoteDocument");
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

            var campagneId = noteDocument.Get().CreatedForCampagneId;
            if (_userContext.User.UserIdentifier != noteDocument.Get().CreatingUserId)
            {
                // check if user is allowed to see document
                var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
                {
                    CampagneId = campagneId,
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

                // there is nothing to see in this document for user
                if (
                    !noteDocument
                        .Get()
                        .NoteBlocks.Any(b =>
                            b.Visibility == NotesBlockVisibility.VisibleForCampagne
                            || b.PermittedUsers.Contains(_userContext.User.UserIdentifier)
                        )
                )
                {
                    return Unauthorized();
                }
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
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(NoteBlockModelBase.NoteBlockModelBaseIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createtextblock/{notedocumentid}")]
        public async Task<
            ActionResult<NoteBlockModelBase.NoteBlockModelBaseIdentifier>
        > CreateTextBlockForDocumentAsync(
            [FromBody] [Required] TextBlock textBlockToCreate,
            [FromRoute] string notedocumentid,
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

            textBlockToCreate.NoteDocumentId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed);
            textBlockToCreate.CreatingUserId = _userContext.User.UserIdentifier;

            var textBlockCreationResult = await new NoteBlockCreateQuery { ModelToCreate = textBlockToCreate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (textBlockCreationResult.IsNone)
            {
                return BadRequest("Could not create textblock");
            }

            return Ok(textBlockCreationResult.Get());
        }

        /// <summary>
        /// Creates a single image block for a given document.
        /// </summary>
        /// <remarks>You must be the owner of the document</remarks>
        /// <param name="imageBlockToCreate">The new imageblock</param>
        /// <param name="notedocumentid">The document id where this block will be assigned</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The id of the new document</response>
        /// <response code="400">If there was an error retrieving the document</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this document</response>
        [ProducesResponseType(typeof(NoteBlockModelBase.NoteBlockModelBaseIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createimageblock/{notedocumentid}")]
        public async Task<
            ActionResult<NoteBlockModelBase.NoteBlockModelBaseIdentifier>
        > CreateImageBlockForDocumentAsync(
            [FromBody] [Required] ImageBlock imageBlockToCreate,
            [FromRoute] string notedocumentid,
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

            imageBlockToCreate.NoteDocumentId = NoteDocument.NoteDocumentIdentifier.From(notedocumentidparsed);
            imageBlockToCreate.CreatingUserId = _userContext.User.UserIdentifier;

            var imageBlockCreationResult = await new NoteBlockCreateQuery { ModelToCreate = imageBlockToCreate }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageBlockCreationResult.IsNone)
            {
                return BadRequest("Could not create imageblock");
            }

            return Ok(imageBlockCreationResult.Get());
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

            return Ok(documentUpdateResult.Get());
        }
    }
}
