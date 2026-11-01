namespace RPGTableHelper.Shared.Auth
{
    /// <summary>
    /// Authentication scheme name and claim types the API key authentication handler issues.
    /// </summary>
    public static class ApiKeyClaimTypes
    {
        public const string AuthenticationScheme = "ApiKey";

        /// <summary>One claim per granted <see cref="ApiKeyScopes"/> entry.</summary>
        public const string Scope = "scope";

        public const string ApiKeyId = "apikeyid";

        /// <summary>Non-secret key prefix (e.g. <c>sk-AbCd</c>), safe to log.</summary>
        public const string ApiKeyPrefix = "apikeyprefix";
    }
}
