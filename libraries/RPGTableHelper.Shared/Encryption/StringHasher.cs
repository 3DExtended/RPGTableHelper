using System.Security.Cryptography;
using System.Text;

namespace RPGTableHelper.Shared.Encryption
{
    public static class StringHasher
    {
        public static string HashText(string text, string salt, HashAlgorithm? hasher = null)
        {
            if (hasher == null)
            {
                hasher = SHA1.Create();
            }

            byte[] textWithSaltBytes = Encoding.UTF8.GetBytes(string.Concat(text, salt));
            byte[] hashedBytes = hasher.ComputeHash(textWithSaltBytes);
            hasher.Clear();
            return Convert.ToBase64String(hashedBytes);
        }
    }
}
