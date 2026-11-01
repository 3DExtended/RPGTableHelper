using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Dtos.External;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Shared plumbing of the v1 player API controllers: who is calling, campaign membership and the
    /// <see cref="ExternalApiErrorDto"/> error bodies.
    /// </summary>
    [ExternalApiValidation]
    [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ExternalApiErrorDto), StatusCodes.Status429TooManyRequests)]
    public abstract class ExternalApiControllerBase : ControllerBase
    {
        protected ExternalApiControllerBase(IQueryProcessor queryProcessor, IUserContext userContext)
        {
            QueryProcessor = queryProcessor;
            UserContext = userContext;
        }

        protected IQueryProcessor QueryProcessor { get; }

        protected IUserContext UserContext { get; }

        protected Guid CurrentUserId => UserContext.User.UserIdentifier.Value;

        /// <summary>The non-secret prefix of the calling key, for logs.</summary>
        protected string ApiKeySource => "api key " + (User.FindFirst(ApiKeyClaimTypes.ApiKeyPrefix)?.Value ?? "?");

        protected ObjectResult Error(int statusCode, string error, string message, List<string>? problems = null) =>
            StatusCode(
                statusCode,
                new ExternalApiErrorDto
                {
                    Error = error,
                    Message = message,
                    Problems = problems,
                }
            );

        protected ObjectResult NotFoundError(string message) =>
            Error(StatusCodes.Status404NotFound, ExternalApiErrors.NotFound, message);

        protected ObjectResult InvalidRequest(string message, List<string>? problems = null) =>
            Error(StatusCodes.Status400BadRequest, ExternalApiErrors.InvalidRequest, message, problems);

        /// <summary>
        /// The campaign if the caller is its DM or has a character in it, else null. Callers answer null with 404,
        /// so a key cannot probe which campaigns exist.
        /// </summary>
        protected async Task<Campagne?> LoadCampaignAsMemberAsync(Guid campaignId, CancellationToken cancellationToken)
        {
            var campaignIdentifier = Campagne.CampagneIdentifier.From(campaignId);
            var isMember = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = campaignIdentifier,
                UserIdToCheck = UserContext.User.UserIdentifier,
            }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            if (isMember.IsNone || !isMember.Get())
            {
                return null;
            }

            var campaign = await new CampagneQuery { ModelId = campaignIdentifier }
                .RunAsync(QueryProcessor, cancellationToken)
                .ConfigureAwait(false);
            return campaign.IsSome ? campaign.Get() : null;
        }
    }

    /// <summary>
    /// Answers an invalid request body with an <c>invalid_request</c> <see cref="ExternalApiErrorDto"/> instead of
    /// ASP.NET's ProblemDetails, so every error of the player API has the same shape.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class, Inherited = true)]
    public sealed class ExternalApiValidationAttribute : Attribute, IActionFilter, IOrderedFilter
    {
        /// <summary>Before <c>[ApiController]</c>'s own model state filter (order -2000).</summary>
        public int Order => -3000;

        public void OnActionExecuting(ActionExecutingContext context)
        {
            if (context.ModelState.IsValid)
            {
                return;
            }

            var problems = context
                .ModelState.Where(entry => entry.Value?.Errors.Count > 0)
                .SelectMany(entry =>
                    entry.Value!.Errors.Select(error =>
                        $"{(string.IsNullOrEmpty(entry.Key) ? "body" : entry.Key)}: "
                        + (string.IsNullOrEmpty(error.ErrorMessage) ? error.Exception?.Message : error.ErrorMessage)
                    )
                )
                .ToList();

            context.Result = new BadRequestObjectResult(
                new ExternalApiErrorDto
                {
                    Error = ExternalApiErrors.InvalidRequest,
                    Message = "The request is not valid.",
                    Problems = problems,
                }
            );
        }

        public void OnActionExecuted(ActionExecutedContext context) { }
    }
}
