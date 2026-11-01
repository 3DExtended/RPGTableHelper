namespace RPGTableHelper.WebApi.Dtos.ApiKeys
{
    public class CreateApiKeyRequestDto
    {
        public string Name { get; set; } = default!;

        /// <summary>
        /// Scopes to grant (see <c>ApiKeyScopes</c>), e.g. <c>notes:read</c>. At least one is required.
        /// Older clients that send none get the read-only legacy default.
        /// </summary>
        public List<string>? Scopes { get; set; }

        /// <summary>Optional point in time after which the key stops working. Must be in the future.</summary>
        public DateTimeOffset? ExpiresAt { get; set; }
    }
}
