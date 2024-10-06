using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Base;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Books
{
    public class EncryptionChallengeCreateQuery
        : ConditionalCreateQueryBase<
            EncryptionChallenge,
            EncryptionChallenge.EncryptionChallengeIdentifier,
            Guid,
            EncryptionChallengeCreateQuery
        > { }
}
