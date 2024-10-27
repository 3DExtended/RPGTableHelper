using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Encryptions
{
    public class EncryptionChallengeUpdateQuery
        : UpdateCommand<
            EncryptionChallenge,
            EncryptionChallenge.EncryptionChallengeIdentifier,
            Guid,
            EncryptionChallengeUpdateQuery
        > { }
}
