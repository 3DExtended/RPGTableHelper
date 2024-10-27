using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    /// <summary>
    /// Represents a query for signing a string using RSA encryption.
    /// </summary>
    public class RSASignStringQuery : IQuery<string, RSASignStringQuery>
    {
        /// <summary>
        /// Gets or sets the message to be signed.
        /// </summary>
        public string MessageToSign { get; set; } = default!;

        /// <summary>
        /// Gets or sets an optional override for the private key used in signing.
        /// If not set, the default private key will be used.
        /// </summary>
        public Option<string> PrivateKeyOverride { get; set; } = Option.None;
    }
}
