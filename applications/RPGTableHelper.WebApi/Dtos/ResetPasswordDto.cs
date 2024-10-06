namespace RPGTableHelper.WebApi.Dtos
{
    public class ResetPasswordDto
    {
        public string Email { get; set; } = default!;

        public string NewPassword { get; set; } = default!;

        public string ResetCode { get; set; } = default!;

        public string Username { get; set; } = default!;
    }
}
