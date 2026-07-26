using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;
using RPGTableHelper.WebApi.Options;

namespace RPGTableHelper.WebApi.Services.Auth
{
    /// <summary>
    /// Mints the `{ accessToken, refreshToken, expiresIn }` pair returned by every
    /// sign-in path (password login, Apple, register, registerwithapikey). Wraps
    /// <see cref="IJWTTokenGenerator"/> (access JWT) and <see cref="CreateAuthSessionQuery"/>
    /// (opaque refresh token + its <c>AuthSession</c> row) so all callers share the
    /// exact same minting behavior instead of duplicating it per controller.
    /// </summary>
    public interface IAuthTokenPairIssuer
    {
        Task<Option<AuthTokenPairDto>> IssueAsync(
            User.UserIdentifier userId,
            string username,
            CancellationToken cancellationToken
        );
    }

    public class AuthTokenPairIssuer : IAuthTokenPairIssuer
    {
        private readonly IQueryProcessor _queryProcessor;
        private readonly IJWTTokenGenerator _jwtTokenGenerator;
        private readonly JwtOptions _jwtOptions;
        private readonly ISystemClock _systemClock;

        public AuthTokenPairIssuer(
            IQueryProcessor queryProcessor,
            IJWTTokenGenerator jwtTokenGenerator,
            JwtOptions jwtOptions,
            ISystemClock systemClock
        )
        {
            _queryProcessor = queryProcessor;
            _jwtTokenGenerator = jwtTokenGenerator;
            _jwtOptions = jwtOptions;
            _systemClock = systemClock;
        }

        public async Task<Option<AuthTokenPairDto>> IssueAsync(
            User.UserIdentifier userId,
            string username,
            CancellationToken cancellationToken
        )
        {
            var stringToken = _jwtTokenGenerator.GetJWTToken(username, userId.Value.ToString());

            var authSessionResult = await new CreateAuthSessionQuery
            {
                UserId = userId,
                ExpiresAt = _systemClock.Now.AddSeconds(_jwtOptions.RefreshTokenNumberOfSecondsToExpire),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (authSessionResult.IsNone)
            {
                return Option.None;
            }

            return Option.From(
                new AuthTokenPairDto
                {
                    AccessToken = stringToken!,
                    RefreshToken = authSessionResult.Get().PlainRefreshToken,
                    ExpiresIn = _jwtOptions.NumberOfSecondsToExpire,
                }
            );
        }
    }
}
