namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Models
{
    /// <summary>
    /// Represents a response containing a collection of Apple keys.
    /// </summary>
    public class AppleKeysResponse
    {
        /// <summary>
        /// Gets or sets the list of Apple keys.
        /// </summary>
        public List<AppleKey> Keys { get; set; } = default!;
    }
}
