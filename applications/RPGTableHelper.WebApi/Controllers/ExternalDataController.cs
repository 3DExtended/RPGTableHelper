using System.Collections.Generic;
using System.Linq;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("api/external")]
    [Authorize(AuthenticationSchemes = "ApiKey")]
    [ApiExplorerSettings(GroupName = "external")]
    public class ExternalDataController : ControllerBase
    {
        private readonly IQueryProcessor _queryProcessor;
        private readonly IUserContext _userContext;
        private readonly INoteService _noteService;
        private readonly IMapper _mapper;

        public ExternalDataController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            INoteService noteService,
            IMapper mapper
        )
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
            _noteService = noteService;
            _mapper = mapper;
        }

        /// <summary>
        /// Retrieves all characters for the authenticated user (where they are the player).
        /// </summary>
        [HttpGet("characters")]
        public async Task<ActionResult<IEnumerable<PlayerCharacter>>> GetCharacters()
        {
            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(_userContext.User.IdentityProviderId)
            );

            var charactersOption = await new PlayerCharactersForUserAsPlayerQuery { UserId = userId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            var characters = charactersOption.IsNone ? new List<PlayerCharacter>() : charactersOption.Get();

            return Ok(characters);
        }

        /// <summary>
        /// Retrieves a specific character by ID, if the user is authorized to view it.
        /// </summary>
        [HttpGet("characters/{id}")]
        public async Task<ActionResult<PlayerCharacter>> GetCharacter(Guid id)
        {
            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(_userContext.User.IdentityProviderId)
            );
            var characterId = PlayerCharacter.PlayerCharacterIdentifier.From(id);

            var characterOption = await new PlayerCharacterQuery { ModelId = characterId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            if (characterOption.IsNone)
            {
                return NotFound();
            }

            var character = characterOption.Get();

            if (character.PlayerUserId != userId)
            {
                return Forbid();
            }

            return Ok(character);
        }

        /// <summary>
        /// Retrieves all campaigns accessible to the authenticated user (as DM or Player).
        /// </summary>
        [HttpGet("campaigns")]
        public async Task<ActionResult<IEnumerable<Campagne>>> GetCampaigns()
        {
            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(_userContext.User.IdentityProviderId)
            );

            // 1. Get campaigns where user is DM
            var dmCampaignsOption = await new CampagnesForUserAsDmQuery { UserId = userId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            var dmCampaigns = dmCampaignsOption.IsNone ? new List<Campagne>() : dmCampaignsOption.Get();

            var allCampaigns = dmCampaigns.ToList();
            var knownCampaignIds = allCampaigns.Select(c => c.Id).ToHashSet();

            // 2. Get characters to find campaigns where user is Player
            var charactersOption = await new PlayerCharactersForUserAsPlayerQuery { UserId = userId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            var characters = charactersOption.IsNone ? new List<PlayerCharacter>() : charactersOption.Get();

            var playerCampaignIds = characters.Where(c => c.CampagneId != null).Select(c => c.CampagneId!).Distinct();

            foreach (var campaignId in playerCampaignIds)
            {
                if (knownCampaignIds.Contains(campaignId))
                {
                    continue;
                }

                var campaignOption = await new CampagneQuery { ModelId = campaignId }.RunAsync(
                    _queryProcessor,
                    HttpContext.RequestAborted
                );

                if (!campaignOption.IsNone)
                {
                    var campaign = campaignOption.Get();
                    allCampaigns.Add(campaign);
                    knownCampaignIds.Add(campaign.Id);
                }
            }

            return Ok(allCampaigns);
        }

        /// <summary>
        /// Retrieves a specific campaign by ID, if the user is authorized to view it (as DM or Player).
        /// </summary>
        [HttpGet("campaigns/{id}")]
        public async Task<ActionResult<Campagne>> GetCampaign(Guid id)
        {
            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(_userContext.User.IdentityProviderId)
            );
            var campaignId = Campagne.CampagneIdentifier.From(id);

            var campaignOption = await new CampagneQuery { ModelId = campaignId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            if (campaignOption.IsNone)
            {
                return NotFound();
            }

            var campaign = campaignOption.Get();

            if (campaign.DmUserId == userId)
            {
                return Ok(campaign);
            }

            var isPlayerOption = await new CampagneIsUserInCampagneQuery
            {
                UserIdToCheck = userId,
                CampagneId = campaignId,
            }.RunAsync(_queryProcessor, HttpContext.RequestAborted);

            if (isPlayerOption.IsNone || !isPlayerOption.Get())
            {
                return Forbid();
            }

            return Ok(campaign);
        }

        /// <summary>
        /// Retrieves all characters assigned to a specific campaign, if the user is the DM of that campaign.
        /// </summary>
        [HttpGet("campaigns/{id}/characters")]
        public async Task<ActionResult<IEnumerable<PlayerCharacter>>> GetCampaignCharacters(Guid id)
        {
            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(_userContext.User.IdentityProviderId)
            );
            var campaignId = Campagne.CampagneIdentifier.From(id);

            // 1. Check if campaign exists and user is DM
            var campaignOption = await new CampagneQuery { ModelId = campaignId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            if (campaignOption.IsNone)
            {
                return NotFound();
            }

            var campaign = campaignOption.Get();

            if (campaign.DmUserId != userId)
            {
                return Forbid();
            }

            // 2. Get characters for the campaign
            var charactersOption = await new PlayerCharactersForCampagneQuery { CampagneId = campaignId }.RunAsync(
                _queryProcessor,
                HttpContext.RequestAborted
            );

            var characters = charactersOption.IsNone ? new List<PlayerCharacter>() : charactersOption.Get();

            return Ok(characters);
        }

        /// <summary>
        /// Retrieves all note documents for a specific campaign, if the user is authorized.
        /// </summary>
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
