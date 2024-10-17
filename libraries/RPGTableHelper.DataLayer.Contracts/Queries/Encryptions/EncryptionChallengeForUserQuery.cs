using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Encryptions
{
    public class EncryptionChallengeForUserQuery
        : IQuery<EncryptionChallenge, EncryptionChallengeForUserQuery>
    {
        public string Username { get; set; } = default!;
    }
}
