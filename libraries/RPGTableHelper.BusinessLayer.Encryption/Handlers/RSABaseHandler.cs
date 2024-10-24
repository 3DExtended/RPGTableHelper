using System.Security.Cryptography;
using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public abstract class RSABaseHandler<TQuery, TResult> : IQueryHandler<TQuery, TResult>
        where TQuery : IQuery<TResult, TQuery>
    {
        public IQueryHandler<TQuery, TResult> Successor { get; set; } = default!;

        public abstract Task<Option<TResult>> RunQueryAsync(TQuery query, CancellationToken cancellationToken);

        protected static RSA ImportPrivateKey(string pem)
        {
            if (string.IsNullOrEmpty(pem))
            {
                throw new ArgumentNullException("Could not find PEM string for load private key.");
            }

            var rsa = RSA.Create();
            rsa.ImportFromPem(pem.ToCharArray());
            return rsa;
        }

        protected static RSA ImportPublicKey(string pem)
        {
            if (string.IsNullOrEmpty(pem))
            {
                throw new ArgumentNullException("Could not find PEM string to load public key.");
            }

            var rsa = RSA.Create();
            rsa.ImportFromPem(pem.ToCharArray());
            return rsa;
        }
    }
}
