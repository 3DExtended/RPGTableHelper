namespace RPGTableHelper.WebApi.Dtos
{
    public class LoginDto
    {
        public string Username { get; set; }

        public string UserSecretByEncryptionChallenge { get; set; }
    }
}
