using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services;
using RPGTableHelper.WebApi.Services.ConfigRevisions;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class CampagneController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;
        private readonly IConfigRevisionHistoryStore _configRevisionHistoryStore;
        private readonly IHostEnvironment _hostEnvironment;
        private readonly ILogger<CampagneController> _logger;

        public CampagneController(
            IUserContext userContext,
            IQueryProcessor queryProcessor,
            IConfigRevisionHistoryStore configRevisionHistoryStore,
            IHostEnvironment hostEnvironment,
            ILogger<CampagneController> logger
        )
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
            _configRevisionHistoryStore = configRevisionHistoryStore;
            _hostEnvironment = hostEnvironment;
            _logger = logger;
        }

        /// <summary>
        /// Creates a new campagne with the calling user as dm.
        /// </summary>
        /// <param name="createDto">The creation details</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the id of the created campagne.</returns>
        /// <response code="200">The id of the newly created campagne</response>
        /// <response code="400">If the data provided is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(Campagne.CampagneIdentifier), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("createcampagne")]
        public async Task<ActionResult<Campagne.CampagneIdentifier>> CreateNewCampagneAsync(
            [FromBody] [Required] CampagneCreateDto createDto,
            CancellationToken cancellationToken
        )
        {
            if (createDto == null || string.IsNullOrWhiteSpace(createDto.CampagneName))
            {
                return BadRequest("Missing createDto");
            }

            var newJoinCode = await new CampagneNewJoinCodeQuery()
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (newJoinCode.IsNone)
            {
                return BadRequest("Could not generate new join code.");
            }

            var campagneId = await new CampagneCreateQuery
            {
                ModelToCreate = new Campagne
                {
                    Id = Campagne.CampagneIdentifier.From(Guid.Empty),
                    JoinCode = newJoinCode.Get(),
                    CampagneName = createDto.CampagneName,
                    DmUserId = _userContext.User.UserIdentifier,
                    RpgConfiguration = createDto.RpgConfiguration,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagneId.IsNone)
            {
                return BadRequest("Could not create new campagne");
            }

            return Ok(campagneId.Get());
        }

        /// <summary>
        /// Returns a list of campagnes this user is the dm of.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the list of campagnes.</returns>
        /// <response code="200">A list of all campagnes for this user as dm</response>
        /// <response code="400">If there was an error retrieving the campagnes</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(typeof(IReadOnlyList<Campagne>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getcampagnes")]
        public async Task<ActionResult<IReadOnlyList<Campagne>>> GetCampagnesForUserAsDmAsync(
            CancellationToken cancellationToken
        )
        {
            var campagnes = await new CampagnesForUserAsDmQuery { UserId = _userContext.User.UserIdentifier }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagnes.IsNone)
            {
                return BadRequest("Could not retrieve campagnes.");
            }

            return Ok(campagnes.Get());
        }

        /// <summary>
        /// Returns a single of campagne.
        /// </summary>
        /// <remarks>You must be the dm or a player in this campagne</remarks>
        /// <param name="campagneid">The id of the desired campagne</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns the campagne.</returns>
        /// <response code="200">The campagne</response>
        /// <response code="400">If there was an error retrieving the campagnes</response>
        /// <response code="401">If you are not logged in or you are not allowed to see this campagne</response>
        [ProducesResponseType(typeof(Campagne), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("getcampagne/{campagneid}")]
        public async Task<ActionResult<Campagne>> GetCampagneByIdAsync(
            string campagneid,
            CancellationToken cancellationToken
        )
        {
            if (campagneid == null)
            {
                return BadRequest("No valid campagneId passed");
            }

            if (!Guid.TryParse(campagneid, out var campagneidparsed))
            {
                return BadRequest("No valid campagneId passed");
            }

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

            if (isUserInCampagneResult.Get() == false)
            {
                return Unauthorized();
            }

            var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(campagneidparsed) }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (campagne.IsNone)
            {
                return BadRequest("Could not retrieve campagne");
            }

            return Ok(campagne.Get());
        }

    /// <summary>
    /// Updates the merged RPG configuration for a campagne (DM only).
    /// Used by mobile clients for large configs that exceed reliable SignalR invoke size.
    /// Accepts an optional <see cref="CampagneUpdateRpgConfigDto.FromRevision"/> failsafe check.
    /// </summary>
    [ProducesResponseType(typeof(ConfigWriteResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [HttpPut("updatecampagneconfig/{campagneid}")]
    public async Task<ActionResult<ConfigWriteResultDto>> UpdateCampagneRpgConfigAsync(
        string campagneid,
        [FromBody] [Required] CampagneUpdateRpgConfigDto updateDto,
        CancellationToken cancellationToken
    )
    {
        if (string.IsNullOrWhiteSpace(campagneid) || !Guid.TryParse(campagneid, out var campagneIdParsed))
        {
            return BadRequest("No valid campagneId passed");
        }

        if (updateDto == null || string.IsNullOrWhiteSpace(updateDto.RpgConfiguration))
        {
            return BadRequest("Missing rpg configuration");
        }

        var campagne = await new CampagneQuery
            {
                ModelId = Campagne.CampagneIdentifier.From(campagneIdParsed),
            }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return Unauthorized();
        }

        var updateCampagne = campagne.Get();
        var currentRevision = updateCampagne.RpgConfigurationMergedRevision;

        if (updateDto.FromRevision.HasValue && updateDto.FromRevision.Value != currentRevision)
        {
            return Conflict($"Stale fromRevision. Current revision is {currentRevision}.");
        }

        if (updateCampagne.RpgConfiguration == updateDto.RpgConfiguration)
        {
            return Ok(new ConfigWriteResultDto { Revision = currentRevision });
        }

        var oldCold = updateCampagne.RpgConfigurationCold;
        var oldHot = updateCampagne.RpgConfigurationHot;
        var fromColdRev = updateCampagne.RpgConfigurationColdRevision;
        var fromHotRev = updateCampagne.RpgConfigurationHotRevision;

        updateCampagne.RpgConfiguration = updateDto.RpgConfiguration;

        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(updateDto.RpgConfiguration);
        var newCold = slices.ColdJson;
        var newHot = slices.HotJson;
        var coldChanged = !string.Equals(oldCold, newCold, StringComparison.Ordinal);
        var hotChanged = !string.Equals(oldHot, newHot, StringComparison.Ordinal);

        updateCampagne.RpgConfigurationCold = newCold;
        updateCampagne.RpgConfigurationHot = newHot;
        updateCampagne.RpgConfigurationSchemaVersion = slices.SchemaVersion;
        updateCampagne.RpgConfigurationColdRevision = coldChanged ? fromColdRev + 1 : fromColdRev;
        updateCampagne.RpgConfigurationHotRevision = hotChanged ? fromHotRev + 1 : fromHotRev;
        var newRevision = currentRevision + 1;
        updateCampagne.RpgConfigurationMergedRevision = newRevision;

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return BadRequest("Could not update campagne configuration");
        }

        await _configRevisionHistoryStore
            .RecordCampagneSnapshotAsync(campagneIdParsed, newRevision, updateDto.RpgConfiguration, cancellationToken)
            .ConfigureAwait(false);

        await WriteCampagneBackupAsync(campagneIdParsed, updateDto.RpgConfiguration, cancellationToken).ConfigureAwait(false);

        return Ok(new ConfigWriteResultDto { Revision = newRevision });
    }

    /// <summary>
    /// Applies a RFC 6902 JSON Patch to the merged RPG configuration for a campagne (DM only).
    /// Fails with 409 if <see cref="ConfigPatchRequestDto.FromRevision"/> does not match the current revision.
    /// </summary>
    [ProducesResponseType(typeof(ConfigWriteResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [HttpPatch("patchcampagneconfig/{campagneid}")]
    public async Task<ActionResult<ConfigWriteResultDto>> PatchCampagneRpgConfigAsync(
        string campagneid,
        [FromBody] [Required] ConfigPatchRequestDto patchDto,
        CancellationToken cancellationToken
    )
    {
        if (string.IsNullOrWhiteSpace(campagneid) || !Guid.TryParse(campagneid, out var campagneIdParsed))
        {
            return BadRequest("No valid campagneId passed");
        }

        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(campagneIdParsed) }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (campagne.IsNone || campagne.Get().DmUserId != _userContext.User.UserIdentifier)
        {
            return Unauthorized();
        }

        var updateCampagne = campagne.Get();
        var currentRevision = updateCampagne.RpgConfigurationMergedRevision;

        if (patchDto.FromRevision != currentRevision)
        {
            return Conflict($"Stale fromRevision. Current revision is {currentRevision}.");
        }

        if (!ConfigDocumentPatcher.TryApply(updateCampagne.RpgConfiguration, patchDto.Patch, out var resultJson, out var error))
        {
            return BadRequest($"Could not apply patch: {error}");
        }

        var newRevision = currentRevision + 1;
        updateCampagne.RpgConfiguration = resultJson;
        updateCampagne.RpgConfigurationMergedRevision = newRevision;

        var updateResult = await new CampagneUpdateQuery { UpdatedModel = updateCampagne }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (updateResult.IsNone)
        {
            return BadRequest("Could not update campagne configuration");
        }

        await _configRevisionHistoryStore
            .RecordCampagneSnapshotAsync(campagneIdParsed, newRevision, resultJson, cancellationToken)
            .ConfigureAwait(false);

        await WriteCampagneBackupAsync(campagneIdParsed, resultJson, cancellationToken).ConfigureAwait(false);

        return Ok(new ConfigWriteResultDto { Revision = newRevision });
    }

    /// <summary>
    /// Returns the merged RPG configuration for a campagne (DM or player in the campagne), as a patch from
    /// <paramref name="sinceRevision"/> when a matching history snapshot exists, or the full document otherwise.
    /// </summary>
    [ProducesResponseType(typeof(ConfigSnapshotResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [HttpGet("getcampagneconfig/{campagneid}")]
    public async Task<ActionResult<ConfigSnapshotResponseDto>> GetCampagneRpgConfigAsync(
        string campagneid,
        [FromQuery] int? sinceRevision,
        CancellationToken cancellationToken
    )
    {
        if (string.IsNullOrWhiteSpace(campagneid) || !Guid.TryParse(campagneid, out var campagneIdParsed))
        {
            return BadRequest("No valid campagneId passed");
        }

        var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
        {
            CampagneId = Campagne.CampagneIdentifier.From(campagneIdParsed),
            UserIdToCheck = _userContext.User.UserIdentifier,
        }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (isUserInCampagneResult.IsNone || !isUserInCampagneResult.Get())
        {
            return Unauthorized();
        }

        var campagne = await new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(campagneIdParsed) }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (campagne.IsNone)
        {
            return BadRequest("Could not retrieve campagne");
        }

        var current = campagne.Get();
        var currentRevision = current.RpgConfigurationMergedRevision;
        var currentJson = current.RpgConfiguration ?? "{}";

        if (sinceRevision.HasValue && sinceRevision.Value == currentRevision)
        {
            return Ok(
                new ConfigSnapshotResponseDto
                {
                    Kind = "patch",
                    Revision = currentRevision,
                    FromRevision = sinceRevision,
                    Patch = "[]",
                }
            );
        }

        if (sinceRevision.HasValue)
        {
            var snapshot = await _configRevisionHistoryStore
                .GetCampagneSnapshotAsync(campagneIdParsed, sinceRevision.Value, cancellationToken)
                .ConfigureAwait(false);

            if (snapshot != null)
            {
                var patch = ConfigDocumentPatcher.TryBuildTopLevelPatch(snapshot, currentJson);
                if (patch != null)
                {
                    return Ok(
                        new ConfigSnapshotResponseDto
                        {
                            Kind = "patch",
                            Revision = currentRevision,
                            FromRevision = sinceRevision,
                            Patch = patch,
                        }
                    );
                }
            }
        }

        return Ok(new ConfigSnapshotResponseDto { Kind = "full", Revision = currentRevision, FullConfig = currentJson });
    }

    private Task WriteCampagneBackupAsync(Guid campagneId, string rpgConfig, CancellationToken cancellationToken)
    {
        var timestamp = DateTime.Now.ToString("yyyyMMdd");
        return ConfigFileBackupWriter.WriteBackupAsync(
            _hostEnvironment,
            _logger,
            $"{campagneId}-{timestamp}-rpgbackup.json",
            rpgConfig,
            cancellationToken
        );
    }
    }
}
