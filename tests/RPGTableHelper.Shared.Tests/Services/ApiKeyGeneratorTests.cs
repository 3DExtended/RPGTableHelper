using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.Shared.Tests.Services
{
    public class ApiKeyGeneratorTests
    {
        [Fact]
        public void GenerateKey_ShouldReplaceForbiddenCharacters()
        {
            // test a bunch of keys
            for (int i = 0; i < 1000; i++)
            {
                // Arrange
                int keyLength = 32;

                // Act
                string result = ApiKeyGenerator.GenerateKey(keyLength);

                // Assert
                Assert.DoesNotContain("/", result);
                Assert.DoesNotContain("+", result);
            }
        }

        [Fact]
        public void GenerateKey_ShouldReturnUniqueKeys()
        {
            // Arrange
            int keyLength = 32;

            // Act
            string key1 = ApiKeyGenerator.GenerateKey(keyLength);
            string key2 = ApiKeyGenerator.GenerateKey(keyLength);

            // Assert
            Assert.NotEqual(key1, key2);
        }

        [Fact]
        public void GenerateKey_InvalidLength_ShouldThrowException()
        {
            // Arrange
            int invalidLength = 0;

            // Act & Assert
            Assert.Throws<ArgumentOutOfRangeException>(
                () => ApiKeyGenerator.GenerateKey(invalidLength)
            );
        }
    }
}
