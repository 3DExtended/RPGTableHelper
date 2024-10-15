using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Models;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;
using RPGTableHelper.WebApi.Options;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("/[controller]")]
    public class SignInController : ControllerBase
    {
        private readonly AppleAuthOptions _appleAuthOptions;
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISystemClock _systemClock;
        private readonly string minimalAppVersionSupported = "1.1.0";

        public SignInController(
            IHttpClientFactory httpClientFactory,
            IMemoryCache cache,
            IQueryProcessor queryProcessor,
            IConfiguration configuration,
            ISystemClock systemClock,
            AppleAuthOptions appleAuthOptions
        )
        {
            _appleAuthOptions = appleAuthOptions;
            _queryProcessor = queryProcessor;
            _configuration = configuration;
            _systemClock = systemClock;
            _httpClientFactory = httpClientFactory;
            _cache = cache;
        }

        public static string GetJWTToken(
            IConfiguration configuration,
            ISystemClock systemClock,
            string username,
            string userIdentityProviderId
        )
        {
            var issuer = configuration["Jwt:Issuer"];
            var audience = configuration["Jwt:Audience"];
            var key = Encoding.ASCII.GetBytes(configuration["Jwt:Key"] ?? "");

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(
                    new[]
                    {
                        new Claim("Id", Guid.NewGuid().ToString()),
                        new Claim("identityproviderid", userIdentityProviderId), // TODO replace me with the identityproviderid
                        new Claim(JwtRegisteredClaimNames.Name, username),
                        new Claim(JwtRegisteredClaimNames.Sub, username),
                        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                    }
                ),
                Expires = systemClock.Now.DateTime.AddMinutes(200),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha512Signature
                ),
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            var jwtToken = tokenHandler.WriteToken(token);
            var stringToken = tokenHandler.WriteToken(token);
            return stringToken;
        }

        [HttpGet("getminimalversion")]
        public Task<ActionResult<string>> GetMinimalAppVersion(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<string>>(Ok(minimalAppVersionSupported));
        }

        [HttpPost("login")]
        public async Task<ActionResult<string>> LoginAsync(
            [FromBody] LoginDto loginDto,
            CancellationToken cancellationToken
        )
        {
            // Normally Identity handles sign in, but you can do it directly
            var possiblyExistingUserId = await ValidateLogin(
                    loginDto.Username,
                    loginDto.UserSecretByEncryptionChallenge,
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (possiblyExistingUserId.IsSome)
            {
                var username = loginDto.Username;
                var userIdentityProviderId = possiblyExistingUserId.Get().Value.ToString();
                var stringToken = GetJWTToken(
                    _configuration,
                    _systemClock,
                    username,
                    userIdentityProviderId
                );
                return Ok(stringToken);
            }

            return Unauthorized();
        }

        [HttpPost("loginwithapple")]
        public async Task<ActionResult<string>> LoginWithAppleAsync(
            [FromBody] AppleLoginDto loginDto,
            CancellationToken cancellationToken
        )
        {
            var result = await GetAppleIdKeysAsync();

            // Parse keys
            var appleKeys = JsonConvert.DeserializeObject<AppleKeysResponse>(result);
            if (appleKeys == null)
            {
                return BadRequest();
            }

            // decode identitytoken
            var tokenDetails = GetTokenInfo(loginDto.IdentityToken);
            var appleKeyForIdentityToken = appleKeys.Keys.Single(k => k.kid == tokenDetails["kid"]);

            // vertify token with public key:
            string[] parts = loginDto.IdentityToken.Split('.');
            string header = parts[0];
            string payload = parts[1];
            await ValidateJwsE256(appleKeyForIdentityToken, parts, cancellationToken);

            /*
                Verify the nonce for the authentication
            */
            // TODO nonce is something I pass in through flutter. I have to make sure, a given nonce is only used ONCE...
            // var nonce = tokenDetails["nonce"];

            // Verify that the iss field contains https://appleid.apple.com
            if (tokenDetails["iss"] != "https://appleid.apple.com")
            {
                return Unauthorized();
            }

            // Verify that the aud field is the developer’s client_id
            if (tokenDetails["aud"] != _appleAuthOptions.ClientId)
            {
                return Unauthorized();
            }
            // Verify that the time is earlier than the exp value of the token
            var expDateOfToken = DateTime.UnixEpoch.AddSeconds(+long.Parse(tokenDetails["exp"]));

            if (DateTime.UtcNow > expDateOfToken)
            {
                return Unauthorized();
            }

            // generate new token from apple
            var tokenGenerator = new AppleClientSecretGenerator(_cache, _appleAuthOptions);
            var clientSecret = await tokenGenerator.GenerateAsync().ConfigureAwait(false);

            using (var httpClient = _httpClientFactory.CreateClient())
            {
                using (
                    var request = new HttpRequestMessage(
                        new HttpMethod("POST"),
                        "https://appleid.apple.com/auth/token"
                    )
                )
                {
                    var contentList = new List<string>
                    {
                        "client_id=" + _appleAuthOptions.ClientId,
                        "client_secret=" + clientSecret,
                        "code=" + WebUtility.UrlEncode(loginDto.AuthorizationCode),
                        "grant_type=authorization_code",
                    };

                    request.Content = new StringContent(string.Join("&", contentList));
                    request.Content.Headers.ContentType = MediaTypeHeaderValue.Parse(
                        "application/x-www-form-urlencoded"
                    );

                    var response = await httpClient.SendAsync(request);
                    var appleTokenString = await response
                        .Content.ReadAsStringAsync(cancellationToken)
                        .ConfigureAwait(false);

                    if (appleTokenString.Contains("error_description"))
                    {
                        return BadRequest();
                    }

                    var appleTokenResponse = JsonConvert.DeserializeObject<AppleTokenResponse>(
                        appleTokenString
                    )!;

                    // decode id token
                    var appleAuthTokenDetails = GetTokenInfo(appleTokenResponse.id_token);

                    // some string uniquely identifying the user
                    var internalId = appleAuthTokenDetails["sub"];

                    // check if user exists in our db:
                    var possiblyExistingUserId = await new UserExistsByInternalIdQuery
                    {
                        InternalId = internalId,
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
                        var stringToken = GetJWTToken(
                            _configuration,
                            _systemClock,
                            username,
                            userIdentityProviderId
                        );
                        return Ok(stringToken);
                    }
                    else
                    {
                        // create temp registration and wait for app to complete registration by adding an username
                        // we generate a temporary apikey for this user request so they can finish registration using this key and providing a username
                        var temporaryApiKey = Convert
                            .ToBase64String(RandomNumberGenerator.GetBytes(32))
                            .Replace("/", "A")
                            .Replace("+", "b");

                        // save details in cache
                        _cache.GetOrCreate(
                            "registrationapikey" + temporaryApiKey,
                            ent =>
                            {
                                ent.AbsoluteExpiration = DateTime.UtcNow.AddSeconds(
                                    appleTokenResponse.expires_in
                                );
                                return new Dictionary<string, string>
                                {
                                    { "sub", internalId },
                                    { "ref", appleTokenResponse.refresh_token ?? "" },
                                    { "email", appleAuthTokenDetails["email"] },
                                };
                            }
                        );

                        return Ok("redirect" + temporaryApiKey);
                    }
                }
            }
        }

        private static async Task<string> GetAppleIdKeysAsync()
        {
            // todo add caching
            // Download apple keys from here: https://appleid.apple.com/auth/keys
            var url = "https://appleid.apple.com/auth/keys";

            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.GetAsync(url).ConfigureAwait(false);

                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                    return content;
                }
                else
                {
                    // Handle error response here (e.g., log the status code, throw an exception, etc.)
                    throw new HttpRequestException(
                        $"Request failed with status code {response.StatusCode}"
                    );
                }
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
            var googleIdTokenDetails = GetTokenInfo(loginDto.IdentityToken);

            // some string uniquely identifying the user
            var internalId = "google" + googleIdTokenDetails["sub"];

            // check if user exists in our db:
            var possiblyExistingUserId = await new UserExistsByInternalIdQuery
            {
                InternalId = internalId,
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
                var stringToken = GetJWTToken(
                    _configuration,
                    _systemClock,
                    username,
                    userIdentityProviderId
                );
                return Ok(stringToken);
            }
            else
            {
                // create temp registration and wait for app to complete registration by adding an username
                // we generate a temporary apikey for this user request so they can finish registration using this key and providing a username
                var temporaryApiKey = Convert
                    .ToBase64String(RandomNumberGenerator.GetBytes(32))
                    .Replace("/", "A")
                    .Replace("+", "b");

                // save details in cache
                _cache.GetOrCreate(
                    "registrationapikey" + temporaryApiKey,
                    ent =>
                    {
                        ent.AbsoluteExpiration = DateTime.UnixEpoch.AddSeconds(
                            +long.Parse(googleIdTokenDetails["exp"])
                        );

                        return new Dictionary<string, string>
                        {
                            { "sub", internalId! },
                            { "ref", loginDto.AccessToken! },
                            { "email", googleIdTokenDetails["email"]! },
                        };
                    }
                );

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

        [HttpGet("testlogin")]
        [Authorize]
        public Task<ActionResult<string>> TestLoginAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<string>>(Ok(minimalAppVersionSupported));
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

        protected Dictionary<string, string> GetTokenInfo(string? token)
        {
            var TokenInfo = new Dictionary<string, string>();

            var handler = new JwtSecurityTokenHandler();
            var jwtSecurityToken = handler.ReadJwtToken(token ?? "");
            var claims = jwtSecurityToken.Claims.ToList();

            foreach (var claim in claims)
            {
                TokenInfo.Add(claim.Type, claim.Value);
            }
            var headers = jwtSecurityToken.Header.ToList();

            foreach (var header in headers)
            {
                TokenInfo.Add(header.Key, (header.Value.ToString() ?? ""));
            }

            return TokenInfo;
        }

        private async Task ValidateJwsE256(
            AppleKey appleKeyForIdentityToken,
            string[] parts,
            CancellationToken cancellationToken
        )
        {
            var validationResult = await new JwsE256ValidationQuery
            {
                Key = appleKeyForIdentityToken,
                StringParts = parts,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (validationResult.IsNone || validationResult.Get() == false)
            {
                throw new ApplicationException(string.Format("Invalid signature"));
            }
        }

        private async Task<Option<User.UserIdentifier>> ValidateLogin(
            string userName,
            string password,
            CancellationToken cancellationToken
        )
        {
            var result = await new UserLoginQuery { Username = userName, HashedPassword = password }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            return result;
        }
    }
}
