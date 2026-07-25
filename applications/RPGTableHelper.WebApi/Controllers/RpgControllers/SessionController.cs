using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services.Presence;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    /// <summary>
    /// Table session presence for already-accepted DM/players (separate from campagne membership).
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class SessionController : ControllerBase
    {
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISessionPresenceService _sessionPresenceService;

        public SessionController(
            IUserContext userContext,
            IQueryProcessor queryProcessor,
            ISessionPresenceService sessionPresenceService
        )
        {
            _userContext = userContext;
            _queryProcessor = queryProcessor;
            _sessionPresenceService = sessionPresenceService;
        }

        /// <summary>
        /// Marks the calling, already-accepted DM/player as present for a table session in this campagne.
        /// Other users currently in session for this campagne receive a <c>participantOnline</c> SSE event.
        /// </summary>
        /// <param name="campagneid">The id of the campagne to enter a session for.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The user is now marked as present; body lists all currently online user ids</response>
        /// <response code="400">If the campagneid is invalid</response>
        /// <response code="401">If you are not logged in or not the dm/an accepted player of this campagne</response>
        [ProducesResponseType(typeof(SessionEnterResultDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("enter/{campagneid}")]
        public async Task<IActionResult> EnterAsync(string campagneid, CancellationToken cancellationToken)
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

            await _sessionPresenceService
                .EnterAsync(campagneIdParsed, _userContext.User.UserIdentifier.Value, cancellationToken)
                .ConfigureAwait(false);

            // Snapshot after enter: SSE only notifies on transitions, so a late joiner
            // (e.g. DM opening the app) would otherwise never learn who was already online.
            var onlineUserIds = _sessionPresenceService
                .GetOnlineParticipants(campagneIdParsed)
                .Select(id => id.ToString())
                .ToList();

            return Ok(new SessionEnterResultDto { OnlineUserIds = onlineUserIds });
        }

        /// <summary>
        /// Marks the calling user as no longer present for a table session in this campagne.
        /// Remaining participants receive a <c>participantOffline</c> SSE event.
        /// </summary>
        /// <param name="campagneid">The id of the campagne to leave the session for.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <response code="200">The user is no longer marked as present for this campagne's session</response>
        /// <response code="400">If the campagneid is invalid</response>
        /// <response code="401">If you are not logged in</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpPost("leave/{campagneid}")]
        public async Task<IActionResult> LeaveAsync(string campagneid, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(campagneid) || !Guid.TryParse(campagneid, out var campagneIdParsed))
            {
                return BadRequest("No valid campagneId passed");
            }

            await _sessionPresenceService
                .LeaveAsync(campagneIdParsed, _userContext.User.UserIdentifier.Value, cancellationToken)
                .ConfigureAwait(false);

            return Ok();
        }
    }
}
