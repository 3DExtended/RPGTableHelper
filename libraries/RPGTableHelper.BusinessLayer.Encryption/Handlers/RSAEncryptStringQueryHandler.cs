using System.Security.Cryptography;
using System.Text;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class RSAEncryptStringQueryHandler : RSABaseHandler<RSAEncryptStringQuery, string>
    {
        private readonly RSAOptions _options;

        public RSAEncryptStringQueryHandler(RSAOptions options)
        {
            _options = options;
        }

        public override Task<Option<string>> RunQueryAsync(
            RSAEncryptStringQuery query,
            CancellationToken cancellationToken
        )
        {
            var publicKey = ImportPublicKey(
                query.PublicKeyOverride.GetOrRequiredElse(_options.PublicRsaKeyAsPEM)
            );

            var byteCode = Encoding.UTF8.GetBytes(query.StringToEncrypt);

            var encryptedBytes = publicKey.Encrypt(byteCode, RSAEncryptionPadding.Pkcs1);

            var cypherText = Convert.ToBase64String(encryptedBytes);
            publicKey.Clear();

            return Task.FromResult(Option.From(cypherText));
        }
    }
}
