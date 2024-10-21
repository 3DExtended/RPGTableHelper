using Microsoft.Extensions.Caching.Memory;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.Shared.Auth;

namespace RPGTableHelper.WebApi.Services
{
    public class UserContextProvider : IUserContext
    {
        private readonly IHttpContextAccessor _contextAccessor;

        public UserContextProvider(
            IHttpContextAccessor contextAccessor,
            IQueryProcessor queryProcessor,
            IMemoryCache memoryCache
        )
        {
            _contextAccessor = contextAccessor;
            // new Microsoft.AspNetCore.Http.HeaderDictionary.HeaderDictionaryDebugView(new Microsoft.AspNetCore.Http.HttpRequest.HttpRequestDebugView(new Microsoft.AspNetCore.Http.HttpContext.HttpContextDebugView(((Microsoft.AspNetCore.Http.HttpContextAccessor)contextAccessor).HttpContext).Request).Headers).Items[3]

            if (_contextAccessor.HttpContext == null)
            {
                throw new NullReferenceException(
                    "The usercontext could not resolve the httpcontext"
                );
            }

            var usernameClaim = _contextAccessor.HttpContext.User.Claims.SingleOrDefault(c =>
                c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
            );

            if (usernameClaim == null)
            {
                throw new UnauthorizedAccessException("The provided JWT is invalid");
            }

            var identityProviderId = _contextAccessor
                .HttpContext.User.Claims.Single(c => c.Type == "identityproviderid")
                .Value;

            var userId = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                Guid.Parse(identityProviderId)
            );

            Option<DataLayer.Contracts.Models.Auth.User> loadedUser;

            if (memoryCache.TryGetValue(userId, out loadedUser)) { }
            else
            {
                loadedUser = new UserQuery { ModelId = userId }
                    .RunAsync(queryProcessor, default)
                    .GetAwaiter()
                    .GetResult();

                memoryCache.Set(userId, loadedUser, DateTimeOffset.UtcNow.AddHours(4));
            }

            User = new UserIdentity
            {
                Username = usernameClaim.Value,
                IdentityProviderId = identityProviderId,
            };
        }

        public UserIdentity User { get; init; }
    }
}
