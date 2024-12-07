using System;
using System.Collections.Generic;
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

                if (isUserInCampagneResult.Get() == false)
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
            [FromBody] NoteDocumentDto notedocument,
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
    }
}
