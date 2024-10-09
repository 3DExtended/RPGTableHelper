using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    /// <summary>
    /// Represents a query to verify a user's email credentials.
    /// </summary>
    public class UserCredentialsVerifyEmailQuery : IQuery<Unit, UserCredentialsVerifyEmailQuery>
    {
        /// <summary>
        /// Gets or sets the identifier of the user whose email credentials are being verified.
        /// </summary>
        public User.UserIdentifier UserIdentifier { get; set; } = default!;
    }
}
