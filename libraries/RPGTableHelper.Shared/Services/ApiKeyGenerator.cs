using System.Security.Cryptography;

namespace RPGTableHelper.Shared.Services;

public static class ApiKeyGenerator
{
    public static string GenerateKey(int length)
    {
        return Convert
            .ToBase64String(RandomNumberGenerator.GetBytes(length))
            .Replace("/", "A")
            .Replace("+", "b");
    }
}
