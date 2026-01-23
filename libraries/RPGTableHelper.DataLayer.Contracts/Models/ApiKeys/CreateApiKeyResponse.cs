namespace RPGTableHelper.DataLayer.Contracts.Models.ApiKeys
{
    public class CreateApiKeyResponse
    {
        public ApiKeyDto ApiKey { get; set; } = default!;
        public string PlainKey { get; set; } = default!;
    }
}
