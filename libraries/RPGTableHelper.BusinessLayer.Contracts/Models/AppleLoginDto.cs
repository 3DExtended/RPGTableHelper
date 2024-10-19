using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.BusinessLayer.Contracts.Models
{
    public class AppleLoginDetails
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
