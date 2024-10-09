using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class UserCredentials : NodeModelBase<UserCredentials.UserCredentialsIdentifier, Guid>
    {
        public bool? Deleted { get; set; } = false;

        public string? Email { get; set; }

        public bool? EmailVerified { get; set; } = false;

        public EncryptionChallenge.EncryptionChallengeIdentifier? EncryptionChallengeIdentifier { get; set; }

        public string? HashedPassword { get; set; }

        public string? InternalId { get; set; }

        public string? PasswordResetToken { get; set; }

        public DateTimeOffset? PasswordResetTokenExpireDate { get; set; }

        public string? RefreshToken { get; set; }

        public bool SignInProvider { get; set; } = false;

        // Used as identity provider id
        public User.UserIdentifier Userid { get; set; } = default!;

        public string Username { get; set; } = default!;

        public record UserCredentialsIdentifier : Identifier<Guid, UserCredentialsIdentifier> { }
    }
}
