namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// The access + refresh token pair returned after a successful password login.
    /// </summary>
    public class AuthTokenPairDto
    {
        /// <summary>
        /// The short-lived JWT to use as a Bearer token for API requests.
        /// </summary>
        public string AccessToken { get; set; } = default!;

        /// <summary>
        /// The opaque long-lived refresh token. Store this securely on the client;
        /// it is only ever returned once, in plaintext, here.
        /// </summary>
        public string RefreshToken { get; set; } = default!;

        /// <summary>
        /// Number of seconds until <see cref="AccessToken"/> expires.
        /// </summary>
        public long ExpiresIn { get; set; }
    }
}
