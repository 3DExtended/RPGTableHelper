using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Queries;
using RPGTableHelper.DataLayer.SendGrid.Options;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace BookGram.DataLayer.SendGrid.QueryHandlers
{
    public class EmailSendQueryHandler : IQueryHandler<EmailSendQuery, Unit>
    {
        private readonly SendGridOptions _options;

        public EmailSendQueryHandler(SendGridOptions options)
        {
            _options = options;
        }

        public IQueryHandler<EmailSendQuery, Unit> Successor { get; set; }

        public async Task<Option<Unit>> RunQueryAsync(
            EmailSendQuery query,
            CancellationToken cancellationToken
        )
        {
            var apiKey = _options.ApiKey;
            var client = new SendGridClient(apiKey);
            var from = new EmailAddress(_options.FromEmailAddress, _options.FromSenderName);
            var subject = query.Subject;
            var to = new EmailAddress(query.To.Email, query.To.Name);

            var plainTextContent = query.Body;
            var htmlContent = query.Body;

            var mailRecipients = new List<EmailAddress> { to };

            if (query.CC != null && query.CC.IsSome && query.CC.Get().Count > 0)
            {
                mailRecipients.AddRange(
                    query.CC.Get().Select(e => new EmailAddress { Email = e.Email, Name = e.Name })
                );
            }

            var msg = MailHelper.CreateSingleEmailToMultipleRecipients(
                from,
                mailRecipients,
                subject,
                plainTextContent,
                htmlContent
            );
            var response = await client.SendEmailAsync(msg).ConfigureAwait(false);

            return Unit.Value;
        }
    }
}
