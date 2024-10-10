using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.WebApi.Dtos
{
    public class RegisterDto
    {
        /// <summary>
        /// Gets or sets the api key of this user register request.
        /// Either this has to be set or the UserSecret.
        /// </summary>
        public string? ApiKey { get; set; }

        /// <summary>
        /// Gets or sets the email address of the user.
        /// </summary>
        [Required]
        [EmailAddress]
        public string Email { get; set; } = default!;

        /// <summary>
        /// Gets or sets the EncryptionChallengeIdentifier of this register request.
        ///
        /// Has to be set when the UserSecret is provided.
        /// </summary>
        public EncryptionChallenge.EncryptionChallengeIdentifier? EncryptionChallengeIdentifier { get; set; }

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
        public string? UserSecret { get; set; }
    }
}
