using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Models.ApiKeys
{
    /// <summary>
    /// A presented API key that is known, not revoked and not expired, with the user it acts for and the
    /// scopes the user granted it.
    /// </summary>
    public class VerifiedApiKey
    {
        public User User { get; set; } = default!;
        public Guid ApiKeyId { get; set; }
        public string Prefix { get; set; } = default!;
        public List<string> Scopes { get; set; } = new();
    }
}
