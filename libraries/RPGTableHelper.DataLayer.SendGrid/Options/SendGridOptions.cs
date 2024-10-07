using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.DataLayer.SendGrid.Options
{
    /// <summary>
    /// Represents the configuration options for SendGrid integration.
    /// </summary>
    public class SendGridOptions
    {
        /// <summary>
        /// Gets or sets the SendGrid API key.
        /// </summary>
        /// <remarks> Can be null for environments without email verification </remarks>
        public string? ApiKey { get; set; }

        /// <summary>
        /// Gets or sets the email address from which emails will be sent.
        /// </summary>
        /// <remarks> Can be null for environments without email verification </remarks>
        public string? FromEmailAddress { get; set; }

        /// <summary>
        /// Gets or sets the name of the sender for outgoing emails.
        /// </summary>
        /// <remarks> Can be null for environments without email verification </remarks>
        public string? FromSenderName { get; set; }
    }
}
