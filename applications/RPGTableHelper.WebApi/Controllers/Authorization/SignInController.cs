using System.Security.Cryptography;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;
using RPGTableHelper.BusinessLayer.Contracts.Queries;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Extensions;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.Shared.Extensions;
using RPGTableHelper.Shared.Options;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("/[controller]")]
    public class SignInController : ControllerBase
    {
        private readonly IQueryProcessor _queryProcessor;
        private readonly IJWTTokenGenerator _jwtTokenGenerator;

        public SignInController(
            IQueryProcessor queryProcessor,
            IJWTTokenGenerator jwtTokenGenerator
        )
        {
            _queryProcessor = queryProcessor;
            _jwtTokenGenerator = jwtTokenGenerator;
        }

        /// <summary>
        /// This method returns "Welcome" when the provided JWT is valid.
        /// </summary>
        /// <param name="cancellationToken">CancellationToken</param>
        /// <returns>"Welcome"</returns>
        /// <response code="200">Returns the JWT for the user.</response>
        /// <response code="401">If the used jwt is not valid</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [HttpGet("testlogin")]
        [Authorize]
        public Task<ActionResult<string>> TestLoginAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<string>>(Ok("Welcome"));
        }

        /// <summary>
        /// Returns the encryption challenge for a given username.
        /// </summary>
        /// <remarks>
        /// Please note that the client has to provide an RSA public
        /// key in order to receive the encrypted challenge dictionary.
        /// </remarks>
        /// <param name="username">The username of the desired encryption challenge</param>
        /// <param name="encryptedAppPubKey">The public RSA key of the client</param>
        /// <param name="cancellationToken">CancellationToken</param>
        /// <returns>"Welcome"</returns>
        /// <response code="200">Returns the encrypted challenge dict for the user.</response>
        /// <response code="400">If request is not valid (user not found, key not valid, etc.)</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [HttpPost("getloginchallengeforusername/{username}")]
        public async Task<ActionResult<string>> GetChallengeByUsername(
            [FromRoute] string username,
            [FromBody] EncryptedMessageWrapperDto encryptedAppPubKey,
            CancellationToken cancellationToken
        )
        {
            // load challenge for username
            var challenge = await new EncryptionChallengeForUserQuery { Username = username }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (challenge.IsNone)
            {
                return BadRequest("Could not load challenge by username");
            }

            // first decode message from client
            var decryptedMessageFromClient = await new RSADecryptStringQuery
            {
                StringToDecrypt = encryptedAppPubKey.EncryptedMessage,
                PrivateKeyOverride = Option.None, // we want to use the server private key
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (decryptedMessageFromClient.IsNone)
            {
                return BadRequest(
                    "Could not decrypt message from app for challenge by username request"
                );
            }

            var challengeAsJson = challenge.Get().GetChallengeDictSerialized();

            // encrypt challenge with client pubKey
            var encryptedChallenge = await new RSAEncryptStringQuery
            {
                PublicKeyOverride = decryptedMessageFromClient.Get(),
                StringToEncrypt = challengeAsJson,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (encryptedChallenge.IsNone)
            {
                return BadRequest("Could not encrypt challenge for result");
            }

            return Ok(encryptedChallenge.Get());
        }

        /// <summary>
        /// Performs the login with username and password.
        /// </summary>
        /// <param name="loginDto">The username and password</param>
        /// <param name="cancellationToken">CancellationToken</param>
        /// <returns>A JWT if everything worked</returns>
        /// <response code="200">Returns the jwt for the user</response>
        /// <response code="401">If username or password did not match</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status401Unauthorized)]
        [HttpPost("login")]
        public async Task<ActionResult<string>> LoginWithUsernameAndPasswordAsync(
            [FromBody] LoginWithUsernameAndPasswordDto loginDto,
            CancellationToken cancellationToken
        )
        {
            // Normally Identity handles sign in, but you can do it directly
            var possiblyExistingUserId = await new UserLoginQuery
            {
                Username = loginDto.Username,
                HashedPassword = loginDto.UserSecretByEncryptionChallenge,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (possiblyExistingUserId.IsSome)
            {
                var username = loginDto.Username;
                var userIdentityProviderId = possiblyExistingUserId.Get().Value.ToString();
                var stringToken = _jwtTokenGenerator.GetJWTToken(username, userIdentityProviderId);
                return Ok(stringToken);
            }

            return Unauthorized();
        }

        [HttpPost("loginwithapple")]
        public async Task<ActionResult<string>> LoginWithAppleAsync(
            [FromBody] AppleLoginDetails loginDto,
            CancellationToken cancellationToken
        )
        {
            var appleDetails = await new AppleVerifyTokenAndReceiveUserDetailsQuery { }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (appleDetails.IsNone)
                return Unauthorized();

            var internalId = appleDetails.Get().internalId;
            var email = appleDetails.Get().email;
            var appleRefreshToken = appleDetails.Get().appleRefreshToken;

            // check if user exists in our db:
            var possiblyExistingUserId = await new UserExistsByInternalIdQuery
            {
                SignInProviderId = internalId,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (possiblyExistingUserId.IsSome)
            {
                // user already exists in db.
                // hence we want to load user and return jwt for this user
                var user = await new UserQuery { ModelId = possiblyExistingUserId.Get() }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (user.IsNone)
                {
                    return BadRequest();
                }

                var stringToken = _jwtTokenGenerator.GetJWTToken(
                    user.Get().Username!,
                    possiblyExistingUserId!.Get()!.Value!.ToString()
                );
                return Ok(stringToken);
            }
            else
            {
                // create temp registration and wait for app to complete registration by adding an username
                // we generate a temporary apikey for this user request so they can finish registration using this key and providing a username
                var temporaryApiKey = ApiKeyGenerator.GenerateKey(32);

                // save temporary request in db
                var requestCreateResult = await new OpenSignInProviderRegisterRequestCreateQuery
                {
                    ModelToCreate = new OpenSignInProviderRegisterRequest
                    {
                        Email = email,
                        ExposedApiKey = temporaryApiKey,
                        IdentityProviderId = internalId,
                        SignInProviderRefreshToken = Option.From(appleRefreshToken),
                        SignInProviderUsed = SupportedSignInProviders.Apple,
                    },
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (requestCreateResult.IsNone)
                {
                    return BadRequest();
                }

                return Ok("redirect" + temporaryApiKey);
            }
        }

        [HttpPost("loginwithgoogle")]
        public async Task<ActionResult<string>> LoginWithGoogleAsync(
            [FromBody] GoogleLoginDto loginDto,
            CancellationToken cancellationToken
        )
        {
            if (loginDto == null)
            {
                return BadRequest();
            }

            if (loginDto.AccessToken == null)
            {
                return BadRequest("Expected to find an AccessToken to send to google...");
            }
            if (loginDto.IdentityToken == null)
            {
                return BadRequest("Expected to find an idtoken to validate...");
            }

            try
            {
                // this checks the validity of the token. we only need to make sure we handle the exception state here!
                var payload = await GoogleJsonWebSignature.ValidateAsync(loginDto.IdentityToken);
            }
            catch (InvalidJwtException)
            {
                return Unauthorized();
            }

            // decode id token
            var googleIdTokenDetails = loginDto.IdentityToken.GetTokenInfo();

            // some string uniquely identifying the user
            var internalId = "google" + googleIdTokenDetails["sub"];

            // check if user exists in our db:
            var possiblyExistingUserId = await new UserExistsByInternalIdQuery
            {
                SignInProviderId = internalId,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (possiblyExistingUserId.IsSome)
            {
                // user already exists in db.
                // hence we want to load user and return jwt for this user
                var user = await new UserQuery { ModelId = possiblyExistingUserId.Get() }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (user.IsNone)
                {
                    return BadRequest();
                }

                var username = user.Get().Username;
                var userIdentityProviderId = possiblyExistingUserId.Get().Value.ToString();
                var stringToken = _jwtTokenGenerator.GetJWTToken(username, userIdentityProviderId);
                return Ok(stringToken);
            }
            else
            {
                // create temp registration and wait for app to complete registration by adding an username
                // we generate a temporary apikey for this user request so they can finish registration using this key and providing a username
                var temporaryApiKey = ApiKeyGenerator.GenerateKey(32);

                // save temporary request in db
                var requestCreateResult = await new OpenSignInProviderRegisterRequestCreateQuery
                {
                    ModelToCreate = new OpenSignInProviderRegisterRequest
                    {
                        Email = googleIdTokenDetails["email"]!,
                        ExposedApiKey = temporaryApiKey,
                        IdentityProviderId = internalId!,
                        SignInProviderRefreshToken = Option.None,
                        SignInProviderUsed = SupportedSignInProviders.Google,
                    },
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (requestCreateResult.IsNone)
                    return BadRequest();

                return Ok("redirect" + temporaryApiKey);
            }
        }

        [HttpPost("requestresetpassword")]
        [AllowAnonymous]
        public async Task<ActionResult<string>> RequestPasswordReset(
            [FromBody] ResetPasswordRequestDto requestDto,
            CancellationToken cancellationToken
        )
        {
            if (requestDto == null || requestDto.Email == null || requestDto.Username == null)
            {
                return BadRequest();
            }

            var result = await new UserRequestPasswordResetQuery
            {
                Email = requestDto.Email,
                Username = requestDto.Username,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsSome)
            {
                return Ok("Email sent");
            }

            return BadRequest("Could not create password reset mail or token!");
        }

        [HttpPost("resetpassword")]
        [AllowAnonymous]
        public async Task<ActionResult<string>> UserPasswordReset(
            [FromBody] ResetPasswordDto requestDto,
            CancellationToken cancellationToken
        )
        {
            if (
                requestDto == null
                || requestDto.Email == null
                || requestDto.NewPassword == null
                || requestDto.ResetCode == null
                || requestDto.Username == null
            )
            {
                return BadRequest();
            }

            var result = await new UserPasswordResetQuery
            {
                Email = requestDto.Email,
                Username = requestDto.Username,
                ResetCode = requestDto.ResetCode,
                NewPassword = requestDto.NewPassword,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsSome)
            {
                return Ok("New password set");
            }

            return BadRequest("Could not set new password!");
        }
    }
}
