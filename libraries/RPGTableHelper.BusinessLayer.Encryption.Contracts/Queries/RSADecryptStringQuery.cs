using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    /// <summary>
    /// Represents a query for RSA decryption of a string.
    /// </summary>
    /// <remarks>
    /// This query is used to decrypt a string using RSA encryption. It allows for an optional private key override.
    /// </remarks>
    public class RSADecryptStringQuery : IQuery<string, RSADecryptStringQuery>
    {
        public Option<string> PrivateKeyOverride { get; set; } = Option.None;

        public string StringToDecrypt { get; set; } = default!;
    }
}
