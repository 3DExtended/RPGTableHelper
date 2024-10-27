using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class EncryptionChallenge
        : NodeModelBase<EncryptionChallenge.EncryptionChallengeIdentifier, Guid>
    {
        public string PasswordPrefix { get; set; } = default!;

        public int RndInt { get; set; }

        /// <summary>
        /// Is not yet set if the user is in the process of signing up
        /// </summary>
        public Option<User.UserIdentifier> UserId { get; set; } = default!;

        public record EncryptionChallengeIdentifier
            : Identifier<Guid, EncryptionChallengeIdentifier> { }
    }
}
