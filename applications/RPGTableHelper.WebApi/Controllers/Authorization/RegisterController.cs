using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Models;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Queries;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.WebApi.Controllers.Authorization
{
    [ApiController]
    [Route("/[controller]")]
    public class RegisterController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger _logger;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISystemClock _systemClock;
        private readonly IJWTTokenGenerator _jwtTokenGenerator;

        public RegisterController(
            ILogger logger,
            IQueryProcessor queryProcessor,
            IConfiguration configuration,
            ISystemClock systemClock,
            IJWTTokenGenerator jwtTokenGenerator
        )
        {
            _logger = logger;
            _queryProcessor = queryProcessor;
            _configuration = configuration;
            _systemClock = systemClock;
            _jwtTokenGenerator = jwtTokenGenerator;
        }

        /// <summary>
        /// This method generates a new encryptionChallenge and stores it in the db.
        /// Use this method as first start point for a register operation.
        /// </summary>
        /// <remarks>
        /// Additionally, it uses rsa encryption to comunicate: the client has to provide a public pem
        /// certificate encrypted with the public pem of this server and receives the encryption challenge
        /// RSA encrypted with the provided public cert.
        /// This way, no man in the middle can pretend to be the server as each client has a copy of the public cert of the server.
        /// </remarks>
        /// <param name="encryptedAppPubKey">RSA encrpyted public pem cert of the client.</param>
        /// <param name="cancellationToken">The cancellation token</param>
        /// <returns>A dictionary with the encryptionChallenge encrypted using the provided public cert of the client.</returns>
        /// <response code="200">Returns the JWT for the user.</response>
        /// <response code="400">If the passed user input is invalid</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [AllowAnonymous]
        [HttpPost("createencryptionchallenge")]
        public async Task<ActionResult<string>> CreateNewChallenge(
            [FromBody] string encryptedAppPubKey,
            CancellationToken cancellationToken
        )
        {
            // first decode message from client
            var decryptedMessageFromClient = await new RSADecryptStringQuery
            {
                StringToDecrypt = encryptedAppPubKey,
                PrivateKeyOverride = Option.None, // we want to use the server private key
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (decryptedMessageFromClient.IsNone)
            {
                return BadRequest();
            }

            var appPubKey = decryptedMessageFromClient.Get();

            // generate client challenge
            var challenge = await new EncryptionChallengeGenerateQuery { }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (challenge.IsNone)
            {
                return BadRequest();
            }

            // save challenge in db
            var challengeId = await new EncryptionChallengeCreateQuery
            {
                ModelToCreate = challenge.Get(),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (challengeId.IsNone)
            {
                return BadRequest();
            }

            challenge.Get().Id = challengeId.Get();

            var challengeDict = new Dictionary<string, object>
            {
                ["ri"] = challenge.Get().RndInt,
                ["pp"] = challenge.Get().PasswordPrefix,
                ["id"] = challenge.Get().Id.Value,
            };

            var challengeAsJson = JsonConvert.SerializeObject(challengeDict);

            // encrypt challenge with client pubKey
            var encryptedChallenge = await new RSAEncryptStringQuery
            {
                PublicKeyOverride = appPubKey,
                StringToEncrypt = challengeAsJson,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (encryptedChallenge.IsNone)
            {
                return BadRequest();
            }

            return Ok(encryptedChallenge.Get());
        }

        /// <summary>
        /// Creates a new user with "username and password" sign in.
        /// </summary>
        /// <remarks>
        /// In order to signup the provided body must be RSA encrypted with
        /// the public certificate of this server. The dto must be of type
        /// <see cref="RegisterWithUsernamePasswordDto"/>.
        /// </remarks>
        /// <param name="encryptedRegisterDto">The encrypted register dto</param>
        /// <param name="cancellationToken">cancellationToken</param>
        /// <returns>When valid, the JWT.</returns>
        /// <response code="200">Returns the JWT for the user.</response>
        /// <response code="400">If the passed user input is invalid</response>
        /// <response code="409">If the desired username is already taken</response>
        [HttpPost("register")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [AllowAnonymous]
        public async Task<ActionResult<string>> RegisterAsync(
            [FromBody] string encryptedRegisterDto,
            CancellationToken cancellationToken
        )
        {
            var registerDtoString = await new RSADecryptStringQuery
            {
                StringToDecrypt = encryptedRegisterDto,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (registerDtoString.IsNone)
            {
                return BadRequest();
            }

            var registerDto = JsonConvert.DeserializeObject<RegisterWithUsernamePasswordDto>(
                registerDtoString.Get()
            );

            if (
                registerDto == null
                || registerDto.EncryptionChallengeIdentifier
                    == EncryptionChallenge.EncryptionChallengeIdentifier.From(Guid.Empty)
            )
            {
                return BadRequest();
            }

            // first check if username already exists
            var result = await new UserExistsByUsernameQuery { Username = registerDto.Username }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsSome)
            {
                return Conflict();
            }

            // encrypt email so it is stored safely in database
            var encryptedEmail = await new RSAEncryptStringQuery
            {
                StringToEncrypt = registerDto.Email,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (encryptedEmail.IsNone)
            {
                return BadRequest();
            }

            // create new user and usercredentials
            var usercreateresult = await new UserCreateQuery
            {
                ModelToCreate = new User
                {
                    Username = registerDto.Username,
                    SignInProviderId = Option.None,
                    SignInProvider = Option.None,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (usercreateresult.IsNone)
            {
                return BadRequest();
            }

            var refreshToken = Convert
                .ToBase64String(RandomNumberGenerator.GetBytes(32))
                .Replace("/", "A")
                .Replace("+", "b");

            var userCredentialCreateResult = await new UserCredentialCreateQuery
            {
                ModelToCreate = new UserCredential
                {
                    Email = encryptedEmail.Get(),
                    EncryptionChallengeId = registerDto.EncryptionChallengeIdentifier,
                    HashedPassword = registerDto.UserSecret,
                    RefreshToken = refreshToken,
                    UserId = usercreateresult.Get(),
                    EmailVerified = false,
                    SignInProvider = false,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (userCredentialCreateResult.IsNone)
            {
                return BadRequest();
            }

            var registrationEmailResult = await SendRegistrationEmail(
                    registerDto.Username,
                    registerDto.Email,
                    usercreateresult.Get(),
                    cancellationToken
                )
                .ConfigureAwait(false);

            if (!registrationEmailResult)
            {
                return BadRequest("Could not send registration email to user");
            }

            var token = _jwtTokenGenerator.GetJWTToken(
                registerDto.Username,
                usercreateresult.Get().Value.ToString()
            );
            return Ok(token);
        }

        /// <summary>
        /// Creates a new user for an open sign OpenSignInProviderRegisterRequest.
        /// </summary>
        /// <param name="registerDto">The register dto providing apikey and username</param>
        /// <param name="cancellationToken">cancellationToken</param>
        /// <returns>When valid, the JWT.</returns>
        /// <response code="200">Returns the JWT for the user.</response>
        /// <response code="400">If there was an issue</response>
        /// <response code="401">If there is no open <see cref="OpenSignInProviderRegisterRequest"/></response>
        /// <response code="409">If the open OpenSignInProviderRegisterRequest does not have an email or the username is already taken</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [AllowAnonymous]
        [HttpPost("registerwithapikey")]
        public async Task<ActionResult<string>> RegisterWithApiKeyAsync(
            [FromBody] RegisterWithApiKeyDto registerDto,
            CancellationToken cancellationToken
        )
        {
            // first ensure apikey is known:
            var apiKey = registerDto.ApiKey;

            var signInProviderRegisterRequest =
                await new OpenSignInProviderRegisterRequestExistsByApiKeyQuery { ApiKey = apiKey }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

            if (signInProviderRegisterRequest.IsNone)
            {
                return Unauthorized();
            }

            if (signInProviderRegisterRequest.Get().Email == null)
            {
                return Conflict();
            }

            // first check if username already exists
            var result = await new UserExistsByUsernameQuery { Username = registerDto.Username }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsSome)
            {
                return Conflict();
            }

            var encryptedEmail = await new RSAEncryptStringQuery
            {
                StringToEncrypt = signInProviderRegisterRequest.Get().Email,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (encryptedEmail.IsNone)
            {
                return BadRequest();
            }

            // create new user and usercredentials
            var usercreateresult = await new UserCreateQuery
            {
                ModelToCreate = new User
                {
                    Username = registerDto.Username,
                    SignInProviderId = signInProviderRegisterRequest.Get().IdentityProviderId,
                    SignInProvider = signInProviderRegisterRequest.Get().SignInProviderUsed,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (usercreateresult.IsNone)
            {
                return BadRequest();
            }

            var refreshToken = Convert
                .ToBase64String(RandomNumberGenerator.GetBytes(32))
                .Replace("/", "A")
                .Replace("+", "b");

            var userCredentialCreateResult = await new UserCredentialCreateQuery
            {
                ModelToCreate = new UserCredential
                {
                    EncryptionChallengeId = Option.None,
                    HashedPassword = "",
                    SignInProvider = true,
                    RefreshToken = refreshToken,
                    Email = encryptedEmail.Get(),
                    UserId = usercreateresult.Get(),
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (userCredentialCreateResult.IsNone)
            {
                return BadRequest();
            }

            var registrationEmailResult = await SendRegistrationEmail(
                    registerDto.Username,
                    signInProviderRegisterRequest.Get().Email,
                    usercreateresult.Get(),
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (!registrationEmailResult)
            {
                return BadRequest("Could not send registration mail");
            }

            var token = _jwtTokenGenerator.GetJWTToken(
                registerDto.Username,
                usercreateresult.Get().Value.ToString()
            );

            // delete request from db
            await new OpenSignInProviderRegisterRequestDeleteQuery
            {
                Id = signInProviderRegisterRequest.Get().Id,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            return Ok(token);
        }

        /// <summary>
        /// Lets the user verify their email.
        /// </summary>
        /// <remarks>This link is send via email to the user after registration (and only if the user used username and password login).</remarks>
        /// <param name="useridbase64">The base64 encoded userid</param>
        /// <param name="signaturebase64">The server generated signature for the userid</param>
        /// <param name="cancellationToken">cancellationToken</param>
        /// <returns>A string "Email verified!" if everything worked</returns>
        /// <response code="200">Returns the JWT for the user.</response>
        /// <response code="400">If there was an issue</response>
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [AllowAnonymous]
        [HttpGet("verifyemail/{useridbase64}/{signaturebase64}")]
        public async Task<ActionResult<string>> VerifyEmailAsync(
            string useridbase64,
            string signaturebase64,
            CancellationToken cancellationToken
        )
        {
            // "https://www.your-shelf.app/api/register/verifyemail/?key={useridbase64}&sig={signbase64}"
            var userIdStr = Encoding.UTF8.GetString(
                Convert.FromBase64String(useridbase64.Replace('_', '/'))
            );

            // first verfiy signature for email verification
            var isVerified = await new RSAVerifySignatureForStringQuery
            {
                OriginalMessage = userIdStr,
                Signature = signaturebase64.Replace('_', '/'),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isVerified.IsNone)
            {
                return BadRequest("The signature is not matching!");
            }

            // verify email
            var result = await new UserCredentialConfirmEmailQuery
            {
                UserIdentifier = DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(
                    Guid.Parse(userIdStr)
                ),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsNone)
            {
                return BadRequest("Could not verify email");
            }
            else
            {
                return Ok("Email verified!");
            }
        }

        private async Task<bool> SendRegistrationEmail(
            string username,
            string email,
            User.UserIdentifier userIdentifier,
            CancellationToken cancellationToken
        )
        {
            var useridAsString = userIdentifier.Value.ToString();
            var userIdSignature = await new RSASignStringQuery { MessageToSign = useridAsString }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (userIdSignature.IsNone)
            {
                return false;
            }

            var useridbase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(useridAsString));

            // "https://www.your-shelf.app/api/register/verifyemail/?key={useridbase64}&sig={signbase64}"
            var verifyEmailUrl =
                $"https://your-shelf.app/api/register/verifyemail/?key={useridbase64.Replace('/', '_')}&sig={userIdSignature.Get().Replace('/', '_')}";

            var sendEmailResult = await new EmailSendQuery
            {
                To = new EmailAddress { Name = email, Email = email },
                CC = new List<EmailAddress>(),
                Subject = "Registrierung",
                Body =
                    @$"Hallo {username}, <br><br>

                    Damit deine Registrierung abgeschlossen werden kann, klicke bitte auf den folgenden Link:<br><br>

                    {verifyEmailUrl} <br><br>

                    Vielen vielen Dank fürs Registrieren!<br>
                    Peter (der Entwickler ;) )<br><br>

                    P.S.: Falls du Fragen hast, kannst du mich jederzeit erreichen: <br>
                    Über Twitter @PeterEsser_ <br><br>

                    Falls du Fragen zu dieser Mail hast, dir irgendetwas merkwürdig vorkommt oder du keine Registrierung für die App YourShelf gemacht hast, kannst du auf diese E-Mail antworten und wir klären das!
                    ",
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (sendEmailResult.IsNone)
            {
                return false;
            }

            return true;
        }
    }
}
