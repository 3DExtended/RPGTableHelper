using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Base;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Encryptions
{
    public class EncryptionChallengeCreateQuery
        : CreateQuery<
            EncryptionChallenge,
            EncryptionChallenge.EncryptionChallengeIdentifier,
            Guid,
            EncryptionChallengeCreateQuery
        > { }
}
