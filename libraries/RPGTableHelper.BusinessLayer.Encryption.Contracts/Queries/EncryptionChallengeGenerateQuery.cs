using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    public class EncryptionChallengeGenerateQuery
        : IQuery<EncryptionChallenge, EncryptionChallengeGenerateQuery> { }
}
