using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class UserCredential : NodeModelBase<UserCredential.UserCredentialIdentifier, Guid>
    {
        public bool Deleted { get; set; } = false;

        public Option<string> Email { get; set; }

        public Option<bool> EmailVerified { get; set; } = false;

        public Option<EncryptionChallenge.EncryptionChallengeIdentifier> EncryptionChallengeId { get; set; }

        public Option<string> HashedPassword { get; set; }

        public Option<string> PasswordResetToken { get; set; }

        public Option<DateTimeOffset> PasswordResetTokenExpireDate { get; set; }

        public Option<string> RefreshToken { get; set; }

        public bool SignInProvider { get; set; } = false;

        public User.UserIdentifier UserId { get; set; } = default!;

        public record UserCredentialIdentifier : Identifier<Guid, UserCredentialIdentifier> { }
    }
}
