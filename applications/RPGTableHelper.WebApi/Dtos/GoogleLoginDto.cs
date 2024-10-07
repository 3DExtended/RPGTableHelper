using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Data Transfer Object for Google login information.
    /// </summary>
    public class GoogleLoginDto
    {
        /// <summary>
        /// Gets or sets the Google Access Token.
        /// </summary>
        [Required]
        public string AccessToken { get; set; } = default!;

        /// <summary>
        /// Gets or sets the Google Identity Token.
        /// </summary>
        [Required]
        public string IdentityToken { get; set; } = default!;
    }
}
