using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class EncryptionChallenge
        : NodeModelBase<EncryptionChallenge.EncryptionChallengeIdentifier>
    {
        public string PasswordPrefix { get; set; } = default!;

        public int RndInt { get; set; }

        public record EncryptionChallengeIdentifier
            : Identifier<Guid, EncryptionChallengeIdentifier> { }
    }
}
