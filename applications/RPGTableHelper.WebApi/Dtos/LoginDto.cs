using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Data Transfer Object for user login information.
    /// </summary>
    public class LoginDto
    {
        /// <summary>
        /// Gets or sets the username of the user.
        /// </summary>
        [Required]
        public string Username { get; set; } = default!;

        /// <summary>
        /// Gets or sets the hashed password of the user.
        /// Either this has to be set or the ApiKey.
        ///
        /// If this is set, the user is registering in with username + password, if not set,
        /// the user is providing username and password after the sign in using a OIDC Provider
        /// (like apple or google).
        /// </summary>
        [Required]
        public string UserSecretByEncryptionChallenge { get; set; } = default!;
    }
}
