using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    public class AppleLoginDto
    {
        /// <summary>
        /// Gets or sets the Apple Identity Token.
        /// </summary>
        [Required]
        public string AuthorizationCode { get; set; } = default!;

        /// <summary>
        /// Gets or sets the Apple Identity Token.
        /// </summary>
        [Required]
        public string IdentityToken { get; set; } = default!;
    }
}
