using System.Security.Cryptography;
using System.Text;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class RSAVerifySignatureForStringQueryHandler
        : RSABaseHandler<RSAVerifySignatureForStringQuery, bool>
    {
        private readonly RSAOptions _options;

        public RSAVerifySignatureForStringQueryHandler(RSAOptions options)
        {
            _options = options;
        }

        public override IQueryHandler<
            RSAVerifySignatureForStringQuery,
            bool
        >? Successor { get; set; }

        public override Task<Option<bool>> RunQueryAsync(
            RSAVerifySignatureForStringQuery query,
            CancellationToken cancellationToken
        )
        {
            var publicKey = this.ImportPublicKey(
                query.PublicKeyOverride.GetOrElse(_options.PublicRsaKeyAsPEM)
            );

            try
            {
                byte[] messageBytes = Encoding.UTF8.GetBytes(query.OriginalMessage);
                var signature = Convert.FromBase64String(query.Signature);

                bool isVerified = publicKey.VerifyData(
                    messageBytes,
                    signature,
                    HashAlgorithmName.SHA256,
                    RSASignaturePadding.Pkcs1
                );
                publicKey.Clear();
                return Task.FromResult(Option.From(isVerified));
            }
            catch
            {
                return Task.FromResult(Option.From(false));
            }
        }
    }
}
