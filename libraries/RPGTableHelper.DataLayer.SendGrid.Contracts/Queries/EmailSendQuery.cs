using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Models;

namespace RPGTableHelper.DataLayer.SendGrid.Contracts.Queries
{
    public class EmailSendQuery : IQuery<Unit, EmailSendQuery>
    {
        public string Body { get; set; } = default!;

        public Option<List<EmailAddress>> CC { get; set; } = Option.None;

        public string Subject { get; set; } = default!;

        public EmailAddress To { get; set; } = default!;
    }
}
