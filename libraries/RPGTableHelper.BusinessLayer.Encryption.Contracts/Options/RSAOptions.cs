namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Options
{
    /// <summary>
    /// Represents RSA key options for encryption operations.
    /// </summary>
    public class RSAOptions
    {
        /// <summary>
        /// Gets or initializes the private RSA key in PEM format.
        /// </summary>
        /// <remarks>
        /// This property should be handled with care due to its sensitive nature.
        /// Ensure it is not logged or serialized in plain text.
        /// </remarks>
        public string PrivateRsaKeyAsPEM { get; set; } = default!;

        /// <summary>
        /// Gets or initializes the public RSA key in PEM format.
        /// </summary>
        public string PublicRsaKeyAsPEM { get; set; } = default!;
    }
}
