using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Models;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Queries;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.UserCredentials
{
    public class UserRequestPasswordResetQueryHandler
        : IQueryHandler<UserRequestPasswordResetQuery, Unit>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _systemClock;
        private readonly IQueryProcessor _queryProcessor;

        public UserRequestPasswordResetQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock,
            IQueryProcessor queryProcessor
        )
        {
            _contextFactory = contextFactory;
            _systemClock = systemClock;
            _queryProcessor = queryProcessor;
        }

        public IQueryHandler<UserRequestPasswordResetQuery, Unit> Successor { get; set; } =
            default!;

        public async Task<Option<Unit>> RunQueryAsync(
            UserRequestPasswordResetQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
            {
                var entity = await context
                    .Set<UserCredentialEntity>()
                    .Where((e) => e.User != null && e.User.Username == query.Username)
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                    return Option.None;

                if (
                    entity.SignInProvider == true // resets are only valid for users registered with username and password
                    || string.IsNullOrEmpty(entity.Email) // resets are only valid if a email is setup
                    || !string.IsNullOrEmpty(entity.PasswordResetToken) // requesting resets is only valid if there wasnt a request recently sent
                        && entity.PasswordResetTokenExpireDate != null
                        && _systemClock.Now > entity.PasswordResetTokenExpireDate
                )
                {
                    return Option.None;
                }

                // decode encrypted email
                // decrypt stored email using cert
                var dencryptedEmail = await new RSADecryptStringQuery
                {
                    StringToDecrypt = entity.Email,
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (dencryptedEmail.IsNone)
                {
                    return Option.None;
                }

                if (dencryptedEmail.Get() != query.Email)
                {
                    return Option.None;
                }

                // generate email reset token:
                var temporaryApiKey = ApiKeyGenerator.GenerateJoinCode();
                var expiresIn = DateTimeOffset.UtcNow.AddHours(2);

                entity.PasswordResetToken = temporaryApiKey;
                entity.PasswordResetTokenExpireDate = expiresIn;
                entity.LastModifiedAt = _systemClock.Now;

                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

                // second inform user by email about reset token
                var sendEmailResult = await new EmailSendQuery
                {
                    To = new EmailAddress
                    {
                        Name = dencryptedEmail.Get(),
                        Email = dencryptedEmail.Get(),
                    },
                    CC = new List<EmailAddress>(),
                    Subject = "Passwort zurücksetzen",
                    Body =
                        @$"Hallo {query.Username}, <br><br>

                    Hast du gerade versucht, dein Passwort für deinen Account zurückzusetzen?<br>
                    Falls ja, ist hier der Code, den du nun in die App eingeben musst: <br><br>

                    <strong>{temporaryApiKey}</strong><br><br>

                    Dieser Code ist 2 Stunden gültig!<br>
                    Peter (der Entwickler ;) )<br><br>

                    P.S.: Falls du nicht versucht hast, dein Passwort zurückzusetzen, kannst du diese E-Mail ignorieren.<br>

                    Falls du Fragen zu dieser Mail hast oder dir irgendetwas merkwürdig vorkommt, kannst du auf diese E-Mail antworten und wir klären das!
                    ",
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (sendEmailResult.IsNone)
                {
                    return Option.None;
                }

                return Unit.Value;
            }
        }
    }
}
