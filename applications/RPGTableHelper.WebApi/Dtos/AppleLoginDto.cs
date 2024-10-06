namespace RPGTableHelper.WebApi.Dtos
{
    public class AppleLoginDto
    {
        public string AuthorizationCode { get; set; } = default!;

        public string IdentityToken { get; set; } = default!;
    }
}
