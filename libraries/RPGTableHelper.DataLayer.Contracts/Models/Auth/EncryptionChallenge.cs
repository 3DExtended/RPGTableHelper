using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class EncryptionChallenge
        : NodeModelBase<EncryptionChallenge.EncryptionChallengeIdentifier, Guid>
    {
        public string PasswordPrefix { get; set; } = default!;

        public int RndInt { get; set; }

        public User.UserIdentifier UserId { get; set; } = default!;

        public record EncryptionChallengeIdentifier
            : Identifier<Guid, EncryptionChallengeIdentifier> { }
    }
}
