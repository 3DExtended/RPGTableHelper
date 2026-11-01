using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos.ApiKeys;

namespace RPGTableHelper.WebApi.Controllers.Authorization
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ApiKeysController : ControllerBase
    {
        private readonly IQueryProcessor _queryProcessor;
        private readonly IUserContext _userContext;
        private readonly ISystemClock _systemClock;

        public ApiKeysController(IQueryProcessor queryProcessor, IUserContext userContext, ISystemClock systemClock)
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
            _systemClock = systemClock;
        }

        /// <summary>
        /// Creates a new API key with the given scopes. Only callable with a normal login (JWT): an API key can
        /// never create, list or revoke keys.
        /// </summary>
        /// <response code="200">The new key. <c>plainKey</c> is shown exactly once.</response>
        /// <response code="400">If the name is empty, a scope is unknown, or the expiry lies in the past</response>
        [ProducesResponseType(typeof(CreateApiKeyResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [HttpPost]
        public async Task<ActionResult<CreateApiKeyResponse>> Create([FromBody] CreateApiKeyRequestDto request, CancellationToken cancellationToken)
        {
            var userId = _userContext.User.UserIdentifier.Value;

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest("A key name is required.");
            }

            // Clients from before scopes existed send none: they get what keys could do back then (read only).
            var requestedScopes = request.Scopes ?? ApiKeyScopes.LegacyDefault.ToList();
            var unknownScopes = requestedScopes.Where(s => !ApiKeyScopes.IsKnown(s)).ToList();
            if (unknownScopes.Count > 0)
            {
                return BadRequest($"Unknown scope(s): {string.Join(", ", unknownScopes)}. Known scopes: {string.Join(", ", ApiKeyScopes.All)}.");
            }

            if (requestedScopes.Count == 0)
            {
                return BadRequest("At least one scope is required.");
            }

            if (request.ExpiresAt.HasValue && request.ExpiresAt.Value <= _systemClock.Now)
            {
                return BadRequest("expiresAt must lie in the future.");
            }

            var query = new CreateApiKeyQuery
            {
                UserId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId),
                Name = request.Name.Trim(),
                Scopes = requestedScopes,
                ExpiresAt = request.ExpiresAt.HasValue
                    ? Option.From(request.ExpiresAt.Value)
                    : Option<DateTimeOffset>.None,
            };

            var result = await _queryProcessor.RunQueryAsync(query, cancellationToken);

            if (result.IsNone)
            {
                return NotFound();
            }

            return Ok(result.Get());
        }

        /// <summary>
        /// Gets all API keys for the current user.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ApiKeyDto>>> Get(CancellationToken cancellationToken)
        {
            var userId = _userContext.User.UserIdentifier.Value;

            var query = new GetUserApiKeysQuery
            {
                UserId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId)
            };

            var result = await _queryProcessor.RunQueryAsync(query, cancellationToken);

            if (result.IsNone)
            {
                return NotFound();
            }

            return Ok(result.Get());
        }

        /// <summary>
        /// Revokes an API key.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Revoke(Guid id, CancellationToken cancellationToken)
        {
             var userId = _userContext.User.UserIdentifier.Value;

             var query = new RevokeApiKeyQuery
             {
                 UserId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId),
                 ApiKeyId = id
             };

             // Handler returns true if updated, false if not found or unauthorized
             var success = await _queryProcessor.RunQueryAsync(query, cancellationToken);
             if (success.IsNone)
            {
                return NotFound();
            }

             return NoContent();
        }
    }
}
