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

    public static string GenerateJoinCode()
    {
        var temporaryApiKey =
            string.Join("", Enumerable.Range(0, 3).Select(_ => RandomNumberGenerator.GetInt32(10)))
            + "-"
            + string.Join(
                "",
                Enumerable.Range(0, 3).Select(_ => RandomNumberGenerator.GetInt32(10))
            );
        return temporaryApiKey;
    }
}
