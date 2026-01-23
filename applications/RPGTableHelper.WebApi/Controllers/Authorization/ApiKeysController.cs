using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.Shared.Auth;
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

        public ApiKeysController(IQueryProcessor queryProcessor, IUserContext userContext)
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
        }

        /// <summary>
        /// Creates a new API key.
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<CreateApiKeyResponse>> Create([FromBody] CreateApiKeyRequestDto request, CancellationToken cancellationToken)
        {
            var userId = _userContext.User.UserIdentifier.Value;

            var query = new CreateApiKeyQuery
            {
                UserId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId),
                Name = request.Name
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
