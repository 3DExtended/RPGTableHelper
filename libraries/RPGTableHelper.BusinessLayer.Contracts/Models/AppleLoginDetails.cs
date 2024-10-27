using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.BusinessLayer.Contracts.Models
{
    /// <summary>
    /// The information a client has to provide in order to login with apple.
    /// </summary>
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
