using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    /// <summary>
    /// Represents a query to generate an encryption challenge.
    /// </summary>
    public class EncryptionChallengeGenerateQuery
        : IQuery<EncryptionChallenge, EncryptionChallengeGenerateQuery> { }
}
