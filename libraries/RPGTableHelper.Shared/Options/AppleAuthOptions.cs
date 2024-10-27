namespace RPGTableHelper.Shared.Options
{
    public class AppleAuthOptions
    {
        public string? ClientId { get; set; }

        public int ClientSecretExpiresAfterHours { get; set; } = 24;

        /// <summary>
        /// Key as PEM format
        /// </summary>
        public string? Key { get; set; }

        public string? KeyId { get; set; }

        public string? TeamId { get; set; }
    }
}
