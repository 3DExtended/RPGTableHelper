namespace RPGTableHelper.WebApi.Options
{
    public class AppleAuthOptions
    {
        public string? ClientId { get; set; }

        public int ClientSecretExpiresAfterHours { get; set; } = 24;

        ///
        // Key as PEM format
        ///
        public string? Key { get; set; }

        public string? KeyId { get; set; }

        public string? TeamId { get; set; }
    }
}
