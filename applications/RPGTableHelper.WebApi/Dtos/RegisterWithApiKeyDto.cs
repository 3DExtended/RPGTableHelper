using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.WebApi.Dtos
{
    public class RegisterWithApiKeyDto
    {
        /// <summary>
        /// Gets or sets the api key of this user register request.
        /// Either this has to be set or the UserSecret.
        /// </summary>
        [Required]
        public string ApiKey { get; set; } = default!;

        /// <summary>
        /// Gets or sets the username of the user.
        /// </summary>
        [Required]
        public string Username { get; set; } = default!;
    }
}
