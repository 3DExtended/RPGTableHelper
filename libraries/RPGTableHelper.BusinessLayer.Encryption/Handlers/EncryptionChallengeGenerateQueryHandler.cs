using System.Security.Cryptography;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class EncryptionChallengeGenerateQueryHandler
        : IQueryHandler<EncryptionChallengeGenerateQuery, EncryptionChallenge>
    {
        public IQueryHandler<
            EncryptionChallengeGenerateQuery,
            EncryptionChallenge
        > Successor { get; set; } = default!;

        public Task<Option<EncryptionChallenge>> RunQueryAsync(
            EncryptionChallengeGenerateQuery query,
            CancellationToken cancellationToken
        )
        {
            return Task.FromResult(
                Option.From(
                    new EncryptionChallenge
                    {
                        PasswordPrefix = ApiKeyGenerator.GenerateKey(32),
                        RndInt = RandomNumberGenerator.GetInt32(int.MaxValue - 1),
                    }
                )
            );
        }
    }
}
