using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Models;

namespace RPGTableHelper.DataLayer.SendGrid.Contracts.Queries
{
    /// <summary>
    /// Sends an email to a list a recipient based on the options provided to EmailSendQueryHandler.
    /// </summary>
    public class EmailSendQuery : IQuery<Unit, EmailSendQuery>
    {
        /// <summary>
        /// The emails content
        /// </summary>
        public string Body { get; set; } = default!;

        /// <summary>
        /// Set this to relay your message to other recipients as well.
        /// </summary>
        public Option<List<EmailAddress>> CC { get; set; } = Option.None;

        /// <summary>
        /// The subject of the email.
        /// </summary>
        public string Subject { get; set; } = default!;

        /// <summary>
        /// Where this email will be send.
        /// </summary>
        public EmailAddress To { get; set; } = default!;
    }
}
