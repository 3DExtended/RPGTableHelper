using System.Security.Cryptography;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class RSADecryptStringQueryHandler : RSABaseHandler<RSADecryptStringQuery, string>
    {
        private readonly RSAOptions _options;

        public RSADecryptStringQueryHandler(RSAOptions options)
        {
            _options = options;
        }

        public override Task<Option<string>> RunQueryAsync(
            RSADecryptStringQuery query,
            CancellationToken cancellationToken
        )
        {
            var privateKey = this.ImportPrivateKey(
                query.PrivateKeyOverride.GetOrRequiredElse(_options.PrivateRsaKeyAsPEM)
            );

            var bytesAppPubKey = privateKey.Decrypt(
                Convert.FromBase64String(query.StringToDecrypt),
                RSAEncryptionPadding.Pkcs1
            );

            var result = System.Text.Encoding.UTF8.GetString(bytesAppPubKey);
            privateKey.Clear();

            return Task.FromResult(Option.From(result));
        }
    }
}
