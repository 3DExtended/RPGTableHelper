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
    public class UserPasswordResetQueryHandler : IQueryHandler<UserPasswordResetQuery, Unit>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _systemClock;
        private readonly IQueryProcessor _queryProcessor;

        public UserPasswordResetQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock,
            IQueryProcessor queryProcessor
        )
        {
            _contextFactory = contextFactory;
            _systemClock = systemClock;
            _queryProcessor = queryProcessor;
        }

        public IQueryHandler<UserPasswordResetQuery, Unit> Successor { get; set; } = default!;

        public async Task<Option<Unit>> RunQueryAsync(UserPasswordResetQuery query, CancellationToken cancellationToken)
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var entity = await context
                    .Set<UserCredentialEntity>()
                    .Where((e) => e.User != null && e.User.Username == query.Username)
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                {
                    return Option.None;
                }

                if (
                    entity.SignInProvider
                    || string.IsNullOrEmpty(entity.Email) // resets are only valid if a email is setup
                    || string.IsNullOrEmpty(entity.PasswordResetToken) // resets are only valid if the PasswordResetToken is set
                    || entity.PasswordResetTokenExpireDate == null // resets are only valid if a PasswordResetTokenExpireDate is set
                    || _systemClock.Now > entity.PasswordResetTokenExpireDate // resets are only valid if the PasswordResetTokenExpireDate is in the past
                )
                {
                    return Option.None;
                }

                // decode encrypted email
                // decrypt stored email using cert
                var dencryptedEmail = await new RSADecryptStringQuery { StringToDecrypt = entity.Email }
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

                // check if user provided reset token is valid
                if (entity.PasswordResetToken.Replace("-", string.Empty) != query.ResetCode.Replace("-", string.Empty))
                {
                    return Option.None;
                }

                entity.HashedPassword = query.NewHashedPassword;
                entity.PasswordResetToken = null;
                entity.PasswordResetTokenExpireDate = null;
                entity.LastModifiedAt = _systemClock.Now;

                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

                // second inform user by email about reset token
                await new EmailSendQuery
                {
                    To = new EmailAddress { Name = dencryptedEmail.Get(), Email = dencryptedEmail.Get() },
                    CC = new List<EmailAddress>(),
                    Subject = "Passwort zurückgesetzt",
                    Body =
                        @$"Hallo {query.Username}, <br><br>

                    Dein Passwort wurde gerade zurückgesetzt.<br>

                    Peter (der Entwickler ;) )<br><br>

                    P.S.: Falls du dein Passwort nicht geändert hast, ändere bitte umgehend dein Passwort über die App!<br>

                    Falls du Fragen zu dieser Mail hast oder dir irgendetwas merkwürdig vorkommt, kannst du auf diese E-Mail antworten und wir klären das!
                    ",
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                return Unit.Value;
            }
        }
    }
}
