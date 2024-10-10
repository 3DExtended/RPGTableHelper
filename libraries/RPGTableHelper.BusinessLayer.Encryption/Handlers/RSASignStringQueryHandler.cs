using System.Security.Cryptography;
using System.Text;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class RSASignStringQueryHandler : RSABaseHandler<RSASignStringQuery, string>
    {
        private readonly RSAOptions _options;

        public RSASignStringQueryHandler(RSAOptions options)
        {
            _options = options;
        }

        public override Task<Option<string>> RunQueryAsync(
            RSASignStringQuery query,
            CancellationToken cancellationToken
        )
        {
            var privateKey = ImportPrivateKey(
                query.PrivateKeyOverride.GetOrRequiredElse(_options.PrivateRsaKeyAsPEM)
            );

            try
            {
                byte[] messageBytes = Encoding.UTF8.GetBytes(query.MessageToSign);

                byte[] signature = privateKey.SignData(
                    messageBytes,
                    HashAlgorithmName.SHA256,
                    RSASignaturePadding.Pkcs1
                );

                var result = Convert.ToBase64String(signature);
                privateKey.Clear();

                return Task.FromResult(Option.From(result));
            }
            catch
            {
                return Task.FromResult(Option<string>.None);
            }
        }
    }
}
