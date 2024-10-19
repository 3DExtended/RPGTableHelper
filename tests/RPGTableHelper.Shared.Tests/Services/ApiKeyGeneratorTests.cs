using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.Shared.Tests.Services
{
    public class ApiKeyGeneratorTests
    {
        [Fact]
        public void GenerateKey_ShouldReplaceForbiddenCharacters()
        {
            // Arrange
            int keyLength = 32;

            // Act
            string result = ApiKeyGenerator.GenerateKey(keyLength);

            // Assert
            Assert.DoesNotContain("/", result);
            Assert.DoesNotContain("+", result);
            Assert.Contains("A", result); // Checking that "/" is replaced
            Assert.Contains("b", result); // Checking that "+" is replaced
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
