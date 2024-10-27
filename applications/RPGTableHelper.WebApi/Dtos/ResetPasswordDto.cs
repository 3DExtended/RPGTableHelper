using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    public class ResetPasswordDto
    {
        /// <summary>
        /// Gets or sets the email address of the user requesting a password reset.
        /// </summary>
        [Required]
        [EmailAddress]
        public string Email { get; set; } = default!;

        /// <summary>
        /// Gets or sets the user requested updated password of the user.
        /// </summary>
        [Required]
        public string NewHashedPassword { get; set; } = default!;

        /// <summary>
        /// Gets or sets the users reset code for the reset password operation.
        /// </summary>
        [Required]
        public string ResetCode { get; set; } = default!;

        /// <summary>
        /// Gets or sets the username of the user requesting a password reset.
        /// </summary>
        [Required]
        public string Username { get; set; } = default!;
    }
}
