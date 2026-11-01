using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Services.Auth;
using RPGTableHelper.WebApi.Services.Characters;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Read and change your own characters' sheets. Every change is checked, stored as a new revision and shown
    /// to the others at the table (<c>characterConfigChanged</c>), so the DM sees e.g. your hit points right away.
    /// </summary>
    [ApiController]
    [Route(ExternalApiRoutes.V1)]
    [Authorize(Policy = ApiKeyAuthorization.ExternalApiPolicy)]
    [ApiExplorerSettings(GroupName = ExternalApiRoutes.SwaggerGroupName)]
    public class ExternalCharacterSheetController : ExternalApiControllerBase
    {
        private static readonly HashSet<string> OpsWithValue = new(StringComparer.Ordinal) { "add", "replace", "test" };

        private readonly ICharacterSheetWriter _characterSheetWriter;

        public ExternalCharacterSheetController(
            IQueryProcessor queryProcessor,
            IUserContext userContext,
            ICharacterSheetWriter characterSheetWriter
        )
            : base(queryProcessor, userContext)
        {
            _characterSheetWriter = characterSheetWriter;
        }

        /// <summary>
        /// The full sheet of one of your characters, with its revision. Stats are stored as
        /// <c>{ statUuid, serializedValue }</c>, where <c>serializedValue</c> is a JSON string; the campaign
        /// configuration says what each stat is.
        /// </summary>
        /// <response code="200">The sheet</response>
        /// <response code="404">If the character does not exist or is not yours</response>
        [RequireScope(ApiKeyScopes.CharactersRead)]
        [ProducesResponseType(typeof(ExternalCharacterSheetDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [HttpGet("characters/{characterId:guid}/sheet")]
        public async Task<ActionResult<ExternalCharacterSheetDto>> GetSheetAsync(
            Guid characterId,
            CancellationToken cancellationToken
        )
        {
            var character = await LoadOwnCharacterAsync(characterId, cancellationToken).ConfigureAwait(false);
            if (character == null)
            {
                return NotFoundError("Character not found.");
            }

            return Ok(
                new ExternalCharacterSheetDto
                {
                    CharacterId = character.Id.Value,
                    CampaignId = character.CampagneId?.Value,
                    Name = character.CharacterName,
                    Revision = character.RpgCharacterConfigurationRevision,
                    Sheet = ExternalJson.ParseStored(character.RpgCharacterConfiguration),
                }
            );
        }

        /// <summary>
        /// Changes the sheet with an RFC 6902 JSON Patch, if it is still at <c>fromRevision</c>. The change is
        /// rejected if it would leave the sheet unreadable for Questkeeper (e.g. a stat value of the wrong type).
        /// </summary>
        /// <response code="200">Saved; the body holds the new revision</response>
        /// <response code="400">If the patch is malformed or does not apply (<c>invalid_patch</c>)</response>
        /// <response code="404">If the character does not exist or is not yours</response>
        /// <response code="409">If the sheet changed since <c>fromRevision</c> (<c>revision_conflict</c>)</response>
        /// <response code="422">If the patched sheet would not be valid (<c>invalid_sheet</c>, see <c>problems</c>)</response>
        [RequireScope(ApiKeyScopes.CharactersWrite)]
        [ProducesResponseType(typeof(ExternalCharacterSheetWriteResultDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status422UnprocessableEntity)]
        [HttpPatch("characters/{characterId:guid}/sheet")]
        public Task<ActionResult<ExternalCharacterSheetWriteResultDto>> PatchSheetAsync(
            Guid characterId,
            [FromBody] [Required] ExternalCharacterSheetPatchRequestDto request,
            CancellationToken cancellationToken
        )
        {
            var patch = new JArray(
                request.Patch.Select(operation =>
                {
                    var json = new JObject { ["op"] = operation.Op, ["path"] = operation.Path };
                    if (operation.From != null)
                    {
                        json["from"] = operation.From;
                    }

                    if (OpsWithValue.Contains(operation.Op))
                    {
                        json["value"] = operation.Value == null ? JValue.CreateNull() : JToken.FromObject(operation.Value);
                    }

                    return json;
                })
            );

            return WriteAsync(characterId, request.FromRevision!.Value, patch, cancellationToken);
        }

        /// <summary>
        /// Sets one stat, e.g. hit points: send the decoded value object, the server encodes it into
        /// <c>serializedValue</c>. With <c>companionUuid</c> the stat of that companion is set instead.
        /// </summary>
        /// <response code="200">Saved; the body holds the new revision</response>
        /// <response code="404">If the character is not yours, or the sheet has no value for this stat yet</response>
        /// <response code="409">If you sent <c>fromRevision</c> and the sheet changed since</response>
        /// <response code="422">If the value does not fit the stat's type (<c>invalid_sheet</c>)</response>
        [RequireScope(ApiKeyScopes.CharactersWrite)]
        [ProducesResponseType(typeof(ExternalCharacterSheetWriteResultDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status409Conflict)]
        [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status422UnprocessableEntity)]
        [HttpPut("characters/{characterId:guid}/sheet/stats/{statUuid}")]
        public async Task<ActionResult<ExternalCharacterSheetWriteResultDto>> SetStatAsync(
            Guid characterId,
            string statUuid,
            [FromBody] [Required] ExternalStatValueRequestDto request,
            [FromQuery] string? companionUuid,
            CancellationToken cancellationToken
        )
        {
            if (request.Value is not JObject value)
            {
                return InvalidRequest("\"value\" must be a JSON object, the decoded serializedValue of the stat.");
            }

            var character = await LoadOwnCharacterAsync(characterId, cancellationToken).ConfigureAwait(false);
            if (character == null)
            {
                return NotFoundError("Character not found.");
            }

            var statPath = FindStatPath(character.RpgCharacterConfiguration, statUuid, companionUuid);
            if (statPath == null)
            {
                return NotFoundError(
                    companionUuid == null
                        ? "The sheet has no value for this stat yet. Add it with PATCH .../sheet."
                        : "The companion does not exist or has no value for this stat yet. Add it with PATCH .../sheet."
                );
            }

            // The test guards the index: if the sheet changed in between, the write fails instead of hitting
            // another stat.
            var patch = new JArray(
                new JObject
                {
                    ["op"] = "test",
                    ["path"] = statPath + "/statUuid",
                    ["value"] = statUuid,
                },
                new JObject
                {
                    ["op"] = "replace",
                    ["path"] = statPath + "/serializedValue",
                    ["value"] = value.ToString(Formatting.None),
                }
            );

            return await WriteAsync(
                    characterId,
                    request.FromRevision ?? character.RpgCharacterConfigurationRevision,
                    patch,
                    cancellationToken
                )
                .ConfigureAwait(false);
        }

        /// <summary>JSON Pointer of the stat entry, e.g. <c>/companionCharacters/0/characterStats/3</c>.</summary>
        private static string? FindStatPath(string? sheetJson, string statUuid, string? companionUuid)
        {
            if (ExternalJson.ParseStored(sheetJson) is not JObject sheet)
            {
                return null;
            }

            var owner = sheet;
            var ownerPath = string.Empty;
            if (companionUuid != null)
            {
                var companions = (sheet["companionCharacters"] as JArray)?.ToList() ?? new List<JToken>();
                var index = companions.FindIndex(c => c is JObject o && (string?)o["uuid"] == companionUuid);
                if (index < 0)
                {
                    return null;
                }

                owner = (JObject)companions[index];
                ownerPath = $"/companionCharacters/{index}";
            }

            if (owner["characterStats"] is not JArray stats)
            {
                return null;
            }

            for (var i = 0; i < stats.Count; i++)
            {
                if (stats[i] is JObject stat && (string?)stat["statUuid"] == statUuid)
                {
                    return $"{ownerPath}/characterStats/{i}";
                }
            }

            return null;
        }

        private async Task<ActionResult<ExternalCharacterSheetWriteResultDto>> WriteAsync(
            Guid characterId,
            int fromRevision,
            JArray patch,
            CancellationToken cancellationToken
        )
        {
            var result = await _characterSheetWriter
                .PatchAsync(
                    characterId,
                    CurrentUserId,
                    fromRevision,
                    patch.ToString(Formatting.None),
                    validate: true,
                    source: ApiKeySource,
                    cancellationToken
                )
                .ConfigureAwait(false);

            return result.Status switch
            {
                CharacterSheetWriteStatus.Saved => Ok(new ExternalCharacterSheetWriteResultDto { Revision = result.Revision }),
                CharacterSheetWriteStatus.NotFound => NotFoundError("Character not found."),
                CharacterSheetWriteStatus.Conflict => Conflict(
                    new ExternalApiErrorDto
                    {
                        Error = ExternalApiErrors.RevisionConflict,
                        Message = "The sheet changed since fromRevision. Load it again and reapply your change.",
                        CurrentRevision = result.Revision,
                    }
                ),
                CharacterSheetWriteStatus.InvalidPatch => Error(
                    StatusCodes.Status400BadRequest,
                    ExternalApiErrors.InvalidPatch,
                    result.Message ?? "The patch does not apply to the sheet."
                ),
                CharacterSheetWriteStatus.InvalidSheet => Error(
                    StatusCodes.Status422UnprocessableEntity,
                    ExternalApiErrors.InvalidSheet,
                    result.Message ?? "The patched sheet would not be valid.",
                    result.Problems.ToList()
                ),
                _ => Error(
                    StatusCodes.Status500InternalServerError,
                    ExternalApiErrors.WriteFailed,
                    "The change could not be stored. Try again later."
                ),
            };
        }

        private async Task<PlayerCharacter?> LoadOwnCharacterAsync(Guid characterId, CancellationToken cancellationToken)
        {
            var character = await new PlayerCharacterQuery
            {
                ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(characterId),
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);

            return character.IsSome && character.Get().PlayerUserId.Value == CurrentUserId ? character.Get() : null;
        }
    }
}
