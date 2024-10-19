using System.Security.Cryptography;

namespace RPGTableHelper.Shared.Services;

public static class ApiKeyGenerator
{
    public static string GenerateKey(int length)
    {
        if (length <= 0)
            throw new ArgumentOutOfRangeException("Length must be bigger than 0");

        return Convert
            .ToBase64String(RandomNumberGenerator.GetBytes(length))
            .Replace("/", "A")
            .Replace("+", "b");
    }
}
