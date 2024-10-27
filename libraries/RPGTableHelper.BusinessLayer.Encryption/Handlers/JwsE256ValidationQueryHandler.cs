using System.Security.Cryptography;
using System.Text;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.Encryption.Handlers
{
    public class JwsE256ValidationQueryHandler : IQueryHandler<JwsE256ValidationQuery, bool>
    {
        public IQueryHandler<JwsE256ValidationQuery, bool> Successor { get; set; } = default!;

        public Task<Option<bool>> RunQueryAsync(JwsE256ValidationQuery query, CancellationToken cancellationToken)
        {
            // Decode the modulus and exponent
            byte[] modulus = Base64UrlDecode(query.Key.n);
            byte[] exponent = Base64UrlDecode(query.Key.e);

            // Create RSA parameters
            RSAParameters rsaParameters = new() { Modulus = modulus, Exponent = exponent };

            // Create an RSA object and import the RSA parameters
            using (RSA rsa = RSA.Create())
            {
                rsa.ImportParameters(rsaParameters);

                // Compute the SHA256 hash of the data to be verified
                using (SHA256 sha256 = SHA256.Create())
                {
                    string dataToVerify = query.StringParts[0] + '.' + query.StringParts[1];
                    byte[] hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(dataToVerify));

                    // Decode the signature
                    byte[] signature = Base64UrlDecode(query.StringParts[2]);

                    // Verify the signature
                    bool isValid = rsa.VerifyHash(hash, signature, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);

                    return Task.FromResult(Option.From(isValid));
                }
            }
        }

        private static byte[] Base64UrlDecode(string input)
        {
            var output = input;
            output = output.Replace('-', '+'); // 62nd char of encoding
            output = output.Replace('_', '/'); // 63rd char of encoding

            // Pad with trailing '='s
            switch (output.Length % 4)
            {
                case 0:
                    break; // No pad chars in this case
                case 1:
                    output += "===";
                    break; // Three pad chars
                case 2:
                    output += "==";
                    break; // Two pad chars
                case 3:
                    output += "=";
                    break; // One pad char
                default:
                    throw new System.Exception("Illegal base64url string!");
            }

            var converted = Convert.FromBase64String(output); // Standard base64 decoder
            return converted;
        }
    }
}
