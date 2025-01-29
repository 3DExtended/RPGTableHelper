using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class PlayerCharacterController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;

        public PlayerCharacterController(IUserContext userContext, IQueryProcessor queryProcessor)
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
        }

        /// <summary>
        /// Creates a new player character with the calling user as owner.
        /// </summary>
        /// <param name="createDto">The creation details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the id of the created player character.</returns>
        /// <response code="200">The id of the newly created player character</response>
        /// <response code="400">If the data provided is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(PlayerCharacter.PlayerCharacterIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createcharacter")]
        public async Task<ActionResult<Campagne.CampagneIdentifier>> CreateNewPlayerCharacterAsync(
            [FromBody] [Required] PlayerCharacterCreateDto createDto,
            CancellationToken cancellationToken
        )
        {
            if (createDto == null || string.IsNullOrWhiteSpace(createDto.CharacterName))
            {
                return BadRequest("Missing createDto");
            }

            var playerId = await new PlayerCharacterCreateQuery
            {
                ModelToCreate = new PlayerCharacter
                {
                    Id = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Empty),
                    CharacterName = createDto.CharacterName,
                    PlayerUserId = _userContext.User.UserIdentifier,
                    RpgCharacterConfiguration = createDto.RpgCharacterConfiguration,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerId.IsNone)
            {
                return BadRequest("Could not create new player character");
            }

            return Ok(playerId.Get());
        }

        /// <summary>
        /// Returns a list of player characters for the calling user.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of playerCharacters.</returns>
        /// <response code="200">A list of all playerCharacters for this user</response>
        /// <response code="400">If there was an error retrieving the playerCharacters</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(IReadOnlyList<PlayerCharacter>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getplayercharacters")]
        public async Task<ActionResult<IReadOnlyList<PlayerCharacter>>> GetPlayerCharactersForUserAsync(
            CancellationToken cancellationToken
        )
        {
            var playerCharacters = await new PlayerCharactersForUserAsPlayerQuery
            {
                UserId = _userContext.User.UserIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacters.IsNone)
            {
                return BadRequest("Could not retrieve playerCharacters.");
            }

            return Ok(playerCharacters.Get());
        }

        /// <summary>
        /// Returns a single playerCharacter.
        /// </summary>
        /// <remarks>You must be the owner of this playerCharacter</remarks>
        /// <param name="playercharacterid">The id of the desired playerCharacter</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the playerCharacter.</returns>
        /// <response code="200">The playerCharacter</response>
        /// <response code="400">If there was an error retrieving the playerCharacters</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this playerCharacter</response>
        [ProducesResponseType(typeof(PlayerCharacter), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getplayercharacter/{playercharacterid}")]
        public async Task<ActionResult<PlayerCharacter>> GetPlayerCharacterByIdAsync(
            string playercharacterid,
            CancellationToken cancellationToken
        )
        {
            if (playercharacterid == null)
            {
                return BadRequest("No valid playercharacterid passed");
            }

            if (!Guid.TryParse(playercharacterid, out var playerCharacteridparsed))
            {
                return BadRequest("No valid playercharacterid passed");
            }

            var playerCharacter = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(playerCharacteridparsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacter.IsNone)
            {
                return BadRequest("Could not retrieve playerCharacter");
            }

            if (playerCharacter.Get().PlayerUserId.Value != _userContext.User.UserIdentifier.Value)
            {
                return Unauthorized();
            }

            return Ok(playerCharacter.Get());
        }

        /// <summary>
        /// Returns a list of player characters for a given campagne.
        /// </summary>
        /// <remarks>Please note that only the dm is allowed to retrieve the rpg character configs of the players. if you are not the dm, those configs will be empty!</remarks>
        /// <param name="campagneIdentifier">The id of the campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of playerCharacters.</returns>
        /// <response code="200">A list of all playerCharacters for this user</response>
        /// <response code="400">If there was an error retrieving the playerCharacters</response>
        /// <response code="401">If you are not logged in or not the dm</response>
        [ProducesResponseType(typeof(IReadOnlyList<PlayerCharacter>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getplayercharactersincampagne")]
        public async Task<ActionResult<IReadOnlyList<PlayerCharacter>>> GetPlayerCharactersForCampagneAsync(
            [FromQuery] [Required] Campagne.CampagneIdentifier campagneIdentifier,
            CancellationToken cancellationToken
        )
        {
            var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = campagneIdentifier,
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

            var campagne = await new CampagneQuery { ModelId = campagneIdentifier }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone)
            {
                return BadRequest("Could not retrieve campagne.");
            }

            var playerCharacters = await new PlayerCharactersForCampagneQuery { CampagneId = campagneIdentifier }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacters.IsNone)
            {
                return BadRequest("Could not retrieve playerCharacters.");
            }

            if (campagne.Get().DmUserId != _userContext.User.UserIdentifier)
            {
                for (var i = 0; i < playerCharacters.Get().Count; i++)
                {
                    playerCharacters.Get()[i].RpgCharacterConfiguration = null;
                }
            }

            return Ok(playerCharacters.Get());
        }

        /// <summary>
        /// Returns a list of all users assigned to the campagne with meta information.
        /// </summary>
        /// <param name="campagneIdentifier">The id of the campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of user details.</returns>
        /// <response code="200">A list of all playerCharacters for this user</response>
        /// <response code="400">If there was an error retrieving the playerCharacters</response>
        /// <response code="401">If you are not logged in or not the dm</response>
        [ProducesResponseType(typeof(IReadOnlyList<NoteDocumentPlayerDescriptorDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getnoteDocumentPlayerDescriptorDtosincampagne")]
        public async Task<
            ActionResult<IReadOnlyList<NoteDocumentPlayerDescriptorDto>>
        > GetNoteDocumentPlayerDescriptorsForCampagneAsync(
            [FromQuery] [Required] Campagne.CampagneIdentifier campagneIdentifier,
            CancellationToken cancellationToken
        )
        {
            var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = campagneIdentifier,
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

            var campagne = await new CampagneQuery { ModelId = campagneIdentifier }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone)
            {
                return BadRequest("Could not retrieve campagne.");
            }

            var playerCharacters = await new PlayerCharactersForCampagneQuery { CampagneId = campagneIdentifier }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (playerCharacters.IsNone)
            {
                return BadRequest("Could not retrieve playerCharacters.");
            }

            var result = new List<NoteDocumentPlayerDescriptorDto>();
            foreach (var playerCharacter in playerCharacters.Get())
            {
                result.Add(
                    new NoteDocumentPlayerDescriptorDto
                    {
                        IsDm = false,
                        IsYou = playerCharacter.PlayerUserId == _userContext.User.UserIdentifier,
                        PlayerCharacterName = playerCharacter.CharacterName,
                        UserId = playerCharacter.PlayerUserId,
                    }
                );
            }

            // Add DM
            result.Add(
                new NoteDocumentPlayerDescriptorDto
                {
                    IsDm = true,
                    IsYou = campagne.Get().DmUserId == _userContext.User.UserIdentifier,
                    PlayerCharacterName = null,
                    UserId = campagne.Get().DmUserId,
                }
            );

            return Ok(result);
        }
    }
}
