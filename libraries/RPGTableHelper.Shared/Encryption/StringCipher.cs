using System.Security.Cryptography;
using System.Text;

namespace RPGTableHelper.Shared.Encryption
{
    public static class StringCipher
    {
        // This constant is used to determine the keysize of the encryption algorithm in bits.
        // We divide this by 8 within the code below to get the equivalent number of bytes.
        private const int Keysize = 256;

        public static string Decrypt(string cipherText, string passPhrase)
        {
            // Get the complete stream of bytes that represent:
            // [32 bytes of Salt] + [32 bytes of IV] + [n bytes of CipherText]
            var cipherTextBytesWithSaltAndIv = Convert.FromBase64String(cipherText);
            // Get the saltbytes by extracting the first 32 bytes from the supplied cipherText bytes.
            var saltStringBytes = cipherTextBytesWithSaltAndIv.Take(Keysize / 8).ToArray();
            // Get the IV bytes by extracting the next 32 bytes from the supplied cipherText bytes.
#pragma warning disable SA1305 // Field names should not use Hungarian notation
            var ivStringBytes = cipherTextBytesWithSaltAndIv.Skip(Keysize / 8).Take(Keysize / 8).ToArray();
#pragma warning restore SA1305 // Field names should not use Hungarian notation
            // Get the actual cipher text bytes by removing the first 64 bytes from the cipherText string.
            var cipherTextBytes = cipherTextBytesWithSaltAndIv
                .Skip(Keysize / 8 * 2)
                .Take(cipherTextBytesWithSaltAndIv.Length - (Keysize / 8 * 2))
                .ToArray();

#pragma warning disable SYSLIB0041 // Type or member is obsolete. Disabled as there are no good translations...
#pragma warning disable S5344 // Passwords should not be stored in plaintext or with a fast hashing algorithm
            using (var password = new Rfc2898DeriveBytes(passPhrase, saltStringBytes, 100002))
            {
                var keyBytes = password.GetBytes(Keysize / 8);
#pragma warning disable SYSLIB0022 // Type or member is obsolete. Disabled as there are no good translations...
                using (var symmetricKey = new RijndaelManaged())
                {
                    symmetricKey.BlockSize = 256;
                    symmetricKey.Mode = CipherMode.CBC;
                    symmetricKey.Padding = PaddingMode.PKCS7;
                    using (var decryptor = symmetricKey.CreateDecryptor(keyBytes, ivStringBytes))
                    {
                        using (var memoryStream = new MemoryStream(cipherTextBytes))
                        {
                            using (var cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Read))
                            {
                                var plainTextBytes = new byte[cipherTextBytes.Length];
                                var decryptedByteCount = cryptoStream.Read(plainTextBytes, 0, plainTextBytes.Length);
                                memoryStream.Close();
                                cryptoStream.Close();
                                return Encoding.UTF8.GetString(plainTextBytes, 0, decryptedByteCount);
                            }
                        }
                    }
                }
#pragma warning restore SYSLIB0022 // Type or member is obsolete
            }
#pragma warning restore S5344 // Passwords should not be stored in plaintext or with a fast hashing algorithm
#pragma warning restore SYSLIB0041 // Type or member is obsolete
        }

        public static string Encrypt(string plainText, string passPhrase)
        {
            // Salt and IV is randomly generated each time, but is preprended to encrypted cipher text
            // so that the same Salt and IV values can be used when decrypting.
            var saltStringBytes = Generate256BitsOfRandomEntropy();
#pragma warning disable SA1305 // Field names should not use Hungarian notation
            var ivStringBytes = Generate256BitsOfRandomEntropy();
#pragma warning restore SA1305 // Field names should not use Hungarian notation
            var plainTextBytes = Encoding.UTF8.GetBytes(plainText);
#pragma warning disable SYSLIB0041 // Type or member is obsolete
#pragma warning disable S5344 // Passwords should not be stored in plaintext or with a fast hashing algorithm
            using (var password = new Rfc2898DeriveBytes(passPhrase, saltStringBytes, 100002))
            {
                var keyBytes = password.GetBytes(Keysize / 8);
#pragma warning disable SYSLIB0022 // Type or member is obsolete
                using (var symmetricKey = new RijndaelManaged())
                {
                    symmetricKey.BlockSize = 256;
                    symmetricKey.Mode = CipherMode.CBC;
                    symmetricKey.Padding = PaddingMode.PKCS7;
                    using (var encryptor = symmetricKey.CreateEncryptor(keyBytes, ivStringBytes))
                    {
                        using (var memoryStream = new MemoryStream())
                        {
                            using (var cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
                            {
                                cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length);
                                cryptoStream.FlushFinalBlock();
                                // Create the final bytes as a concatenation of the random salt bytes, the random iv bytes and the cipher bytes.
                                var cipherTextBytes = saltStringBytes;
                                cipherTextBytes = cipherTextBytes.Concat(ivStringBytes).ToArray();
                                cipherTextBytes = cipherTextBytes.Concat(memoryStream.ToArray()).ToArray();
                                memoryStream.Close();
                                cryptoStream.Close();
                                return Convert.ToBase64String(cipherTextBytes);
                            }
                        }
                    }
                }
#pragma warning restore SYSLIB0022 // Type or member is obsolete
            }
#pragma warning restore S5344 // Passwords should not be stored in plaintext or with a fast hashing algorithm
#pragma warning restore SYSLIB0041 // Type or member is obsolete
        }

        private static byte[] Generate256BitsOfRandomEntropy()
        {
            var randomBytes = new byte[32]; // 32 Bytes will give us 256 bits.
            using (var rngCsp = RandomNumberGenerator.Create())
            {
                // Fill the array with cryptographically secure random bytes.
                rngCsp.GetBytes(randomBytes);
            }

            return randomBytes;
        }
    }
}
