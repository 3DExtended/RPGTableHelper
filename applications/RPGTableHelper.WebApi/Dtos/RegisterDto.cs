using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.WebApi.Dtos
{
    public class RegisterDto
    {
        public string? ApiKey { get; set; }

        public string Email { get; set; }

        public EncryptionChallenge.EncryptionChallengeIdentifier EncryptionChallengeIdentifier { get; set; }

        public string Username { get; set; }

        public string UserSecret { get; set; }
    }
}
