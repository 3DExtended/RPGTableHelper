namespace RPGTableHelper.Shared.Services
{
    public interface IAppleClientSecretGenerator
    {
        Task<string> GenerateAsync();
    }
}
