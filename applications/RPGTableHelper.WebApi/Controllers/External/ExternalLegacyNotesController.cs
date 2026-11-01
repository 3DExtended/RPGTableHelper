using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services;
using RPGTableHelper.WebApi.Services.Auth;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// The note reads of the pre-v1 API, in the app's document shape. v1 serves notes from
    /// <see cref="ExternalNotesController"/> instead; these stay for clients written before it.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.Legacy)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalLegacyNotesController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly INoteService _noteService;
        private readonly IMapper _mapper;

        public ExternalLegacyNotesController(IUserContext userContext, INoteService noteService, IMapper mapper)
        {
            _userContext = userContext;
            _noteService = noteService;
            _mapper = mapper;
        }

        /// <summary>
        /// Retrieves all note documents for a specific campaign, if the user is authorized.
        /// </summary>
        [RequireScope(ApiKeyScopes.NotesRead)]
        [HttpGet("campaigns/{id}/documents")]
        public async Task<ActionResult<IEnumerable<NoteDocumentDto>>> GetDocuments(Guid id)
        {
            var userId = Guid.Parse(_userContext.User.IdentityProviderId);

            var documents = await _noteService.GetNoteDocumentsForUserAsync(id, userId, HttpContext.RequestAborted);

            if (documents.IsNone)
            {
                return NotFound();
            }

            var dtos = documents.Get().Select(_mapper.Map<NoteDocumentDto>);
            return Ok(dtos);
        }

        /// <summary>
        /// Retrieves a specific note document by ID, if the user is authorized.
        /// </summary>
        [RequireScope(ApiKeyScopes.NotesRead)]
        [HttpGet("documents/{id}")]
        public async Task<ActionResult<NoteDocumentDto>> GetDocument(Guid id)
        {
            var userId = Guid.Parse(_userContext.User.IdentityProviderId);

            var document = await _noteService.GetNoteDocumentByIdAsync(id, userId, HttpContext.RequestAborted);

            if (document.IsNone)
            {
                return NotFound();
            }

            var dto = _mapper.Map<NoteDocumentDto>(document.Get());
            return Ok(dto);
        }
    }
}
