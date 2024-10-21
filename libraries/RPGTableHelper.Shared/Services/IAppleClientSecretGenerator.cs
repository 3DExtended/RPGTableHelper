namespace RPGTableHelper.Shared.Services
{
    public interface IAppleClientSecretGenerator
    {
        public Task<string> GenerateAsync();
    }
}
