using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Data Transfer Object for password reset requests.
    /// </summary>
    public class ResetPasswordRequestDto
    {
        /// <summary>
        /// Gets or sets the email address of the user requesting a password reset.
        /// </summary>
        [Required]
        [EmailAddress]
        public string Email { get; set; } = null!;

        /// <summary>
        /// Gets or sets the username of the user requesting a password reset.
        /// </summary>
        [Required]
        public string Username { get; set; } = null!;
    }
}
