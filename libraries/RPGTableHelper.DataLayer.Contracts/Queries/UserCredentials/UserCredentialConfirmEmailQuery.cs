using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials
{
    /// <summary>
    /// Confirms that a user has verified their email
    /// </summary>
    public class UserCredentialConfirmEmailQuery : IQuery<Unit, UserCredentialConfirmEmailQuery>
    {
        /// <summary>
        /// Gets or sets the identifier of the user whose email credentials are being verified.
        /// </summary>
        public User.UserIdentifier UserIdentifier { get; set; } = default!;
    }
}
