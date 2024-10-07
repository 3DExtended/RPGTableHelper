namespace RPGTableHelper.DataLayer.SendGrid.Contracts.Models
{
    /// <summary>
    /// Represents an email address with an optional associated name.
    /// </summary>
    public struct EmailAddress
    {
        /// <summary>
        /// Gets the email address.
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// Gets the name associated with the email address. Can be null or empty.
        /// </summary>
        public string Name { get; set; }
    }
}
