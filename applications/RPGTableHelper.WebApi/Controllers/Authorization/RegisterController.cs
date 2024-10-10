using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Models;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Queries;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Controllers;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.WebApi.Controllers.Authorization
{
    [ApiController]
    [Route("/[controller]")]
    public class RegisterController : ControllerBase
    {
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _configuration;
        private readonly ILogger _logger;
        private readonly IQueryProcessor _queryProcessor;
        private readonly ISystemClock _systemClock;

        public RegisterController(
            ILogger logger,
            IQueryProcessor queryProcessor,
            IMemoryCache cache,
            IConfiguration configuration,
            ISystemClock systemClock
        )
        {
            _logger = logger;
            _queryProcessor = queryProcessor;
            _cache = cache;
            _configuration = configuration;
            _systemClock = systemClock;
        }

        [HttpPost("registerchallenge")]
        public async Task<ActionResult<string>> CreateNewChallenge(
            [FromBody] string encryptedAppPubKey,
            CancellationToken cancellationToken
        )
        {
            // first decode message from client
            var decryptedMessageFromClient = await new RSADecryptStringQuery
            {
                StringToDecrypt = encryptedAppPubKey,
                PrivateKeyOverride =
                    Option.None // we want to use the server private key
                ,
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

        [HttpPost("getloginchallengeforusername/{username}")]
        public async Task<ActionResult<string>> GetChallengeByUsername(
            [FromRoute] string username,
            [FromBody] EncryptedMessageWrapperDto encryptedAppPubKey,
            CancellationToken cancellationToken
        )
        {
            // first decode message from client
            var decryptedMessageFromClient = await new RSADecryptStringQuery
            {
                StringToDecrypt = encryptedAppPubKey.EncryptedMessage,
                PrivateKeyOverride =
                    Option.None // we want to use the server private key
                ,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (decryptedMessageFromClient.IsNone)
            {
                _logger.LogWarning(
                    "Could not decrypt message from app for challenge by username request"
                );
                return BadRequest();
            }

            var appPubKey = decryptedMessageFromClient.Get();

            // load challenge for username
            var challenge = await new EncryptionChallengeForUserQuery { Username = username }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (challenge.IsNone)
            {
                _logger.LogWarning("Could not load challenge by username");

                return BadRequest();
            }

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
                _logger.LogWarning("Could not encrypt challenge for result");

                return BadRequest();
            }

            return Ok(encryptedChallenge.Get());
        }

        [HttpPost("register")]
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

            var registerDto = JsonConvert.DeserializeObject<RegisterDto>(registerDtoString.Get());

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

            if (result.IsNone || result.Get())
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
                ModelToCreate = new User { Username = registerDto.Username },
                UserCredential = new UserCredential
                {
                    Email = encryptedEmail.Get(),
                    EncryptionChallengeId = registerDto.EncryptionChallengeIdentifier,
                    HashedPassword =
                        registerDto.UserSecret // StringHasher.HashText(registerDto.Password, _configuration["Jwt:PasswordSalt"]),
                    ,
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (usercreateresult.IsNone)
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

            var token = SignInController.GetJWTToken(
                _configuration,
                _systemClock,
                registerDto.Username,
                usercreateresult.Get().Value.ToString()
            );
            return Ok(token);
        }

        [HttpPost("registerwithapikey")]
        public async Task<ActionResult<string>> RegisterWithApiKeyAsync(
            [FromBody] RegisterDto registerDto,
            CancellationToken cancellationToken
        )
        {
            // first ensure apikey is known:
            var apiKey = registerDto.ApiKey;

            if (!_cache.TryGetValue("registrationapikey" + apiKey, out var registrationCache))
            {
                return Unauthorized();
            }

            var registrationCacheDict = (Dictionary<string, string>)registrationCache;

            if (registrationCacheDict["email"] == null)
            {
                return Conflict();
            }

            // first check if username already exists
            var result = await new UserExistsByUsernameQuery { Username = registerDto.Username }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (result.IsNone || result.Get())
            {
                return Conflict();
            }

            var encryptedEmail = await new RSAEncryptStringQuery
            {
                StringToEncrypt = registrationCacheDict["email"],
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
                ModelToCreate = new User { Username = registerDto.Username },
                UserCredential = new UserCredential
                {
                    EncryptionChallengeId = EncryptionChallenge.EncryptionChallengeIdentifier.From(
                        Guid.Empty
                    ),
                    HashedPassword = "",
                    SignInProvider = true,
                    RefreshToken = registrationCacheDict["ref"],
                    Email = encryptedEmail.Get(),
                },
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (usercreateresult.IsNone)
            {
                return BadRequest();
            }

            var registrationEmailResult = await SendRegistrationEmail(
                    registerDto.Username,
                    registrationCacheDict["email"],
                    usercreateresult.Get(),
                    cancellationToken
                )
                .ConfigureAwait(false);
            if (!registrationEmailResult)
            {
                return BadRequest("Could not send registration mail");
            }

            var token = SignInController.GetJWTToken(
                _configuration,
                _systemClock,
                registerDto.Username,
                usercreateresult.Get().Value.ToString()
            );
            return Ok(token);
        }

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
            var result = await new UserCredentialVerifyEmailQuery
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
            var useridToSign = userIdentifier.Value.ToString();
            var useridsignature = await new RSASignStringQuery { MessageToSign = useridToSign }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (useridsignature.IsNone)
            {
                return false;
            }

            var signaturebase64 = useridsignature.Get();
            var useridbase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(useridToSign));

            // "https://www.your-shelf.app/api/register/verifyemail/?key={useridbase64}&sig={signbase64}"
            var verifyEmailUrl =
                $"https://your-shelf.app/api/register/verifyemail/?key={useridbase64.Replace('/', '_')}&sig={signaturebase64.Replace('/', '_')}";

            var sendEmailResult = await new EmailSendQuery
            {
                To = new EmailAddress { Name = email, Email = email },
                CC = new List<EmailAddress>(),
                Subject = "YourShelf Registrierung",
                Body =
                    @$"Hallo {username}, <br><br>

                    Damit deine YourShelf Registrierung abgeschlossen werden kann, klicke bitte auf den folgenden Link:<br><br>

                    {verifyEmailUrl} <br><br>

                    Vielen vielen Dank fürs Registrieren!<br>
                    Peter (der YourShelf Entwickler ;) )<br><br>

                    P.S.: Falls du Fragen hast, kannst du mich jederzeit erreichen: <br>
                    Entweder über Twitter @PeterEsser_ oder per Mail an feedback@your-shelf.app <br><br>

                    P.P.S.: Die Datenschutzerklärung findest du hier: https://www.your-shelf.app/datenschutz/ <br>
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
