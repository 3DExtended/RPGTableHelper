using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Body for <c>POST /SignIn/refresh</c>: the opaque refresh token previously issued.
    /// </summary>
    public class RefreshTokenRequestDto
    {
        [Required]
        public string RefreshToken { get; set; } = default!;
    }
}
