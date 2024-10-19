using System.IdentityModel.Tokens.Jwt;
using System.Security.Cryptography;
using FluentAssertions;
using Microsoft.IdentityModel.Tokens;
using RPGTableHelper.Shared.Extensions;

namespace RPGTableHelper.Shared.Tests.Extensions
{
    public class StringExtensionsTests
    {
        [Theory]
        [InlineData("Hello World!", "helloworld")]
        [InlineData("C# is awesome!", "cisawesome")]
        [InlineData("123 ABC !!", "123abc")]
        [InlineData("___Special__!!", "special")]
        [InlineData("", "")]
        public void CustomNormalize_ShouldRemoveSpecialCharactersAndSpaces(
            string input,
            string expected
        )
        {
            // Act
            var result = input.CustomNormalize();

            // Assert
            Assert.Equal(expected, result);
        }

        [Fact]
        public void CustomNormalize_ShouldHandleEmptyString()
        {
            // Arrange
            string input = "";

            // Act
            var result = input.CustomNormalize();

            // Assert
            Assert.Equal("", result);
        }

        [Fact]
        public void CustomNormalize_ShouldRemoveOnlySpecialCharacters()
        {
            // Arrange
            string input = "!@#$%^&*()_+";

            // Act
            var result = input.CustomNormalize();

            // Assert
            Assert.Equal("", result);
        }

        [Theory]
        [InlineData("abc123", true)]
        [InlineData("ABC123", true)]
        [InlineData("123456", true)]
        [InlineData("abcABC", true)]
        [InlineData("abc 123", false)] // Contains space
        [InlineData("abc123!", false)] // Contains special character
        [InlineData("", false)] // Empty string is not alphanumeric
        public void IsAlphaNumeric_ShouldValidateAlphanumericStrings(string input, bool expected)
        {
            // Act
            var result = input.IsAlphaNumeric();

            // Assert
            Assert.Equal(expected, result);
        }

        [Fact]
        public void GetTokenInfo_ShouldReturnClaimsAndHeadersFromValidToken()
        {
            // Arrange
            var handler = new JwtSecurityTokenHandler();
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new System.Security.Claims.ClaimsIdentity(
                    new[]
                    {
                        new System.Security.Claims.Claim("name", "Test User"),
                        new System.Security.Claims.Claim("role", "Admin"),
                    }
                ),
                Expires = DateTime.UtcNow.AddHours(1),
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(RandomNumberGenerator.GetBytes(256)),
                    SecurityAlgorithms.HmacSha256Signature
                ),
            };
            var securityToken = handler.CreateToken(tokenDescriptor);
            var token = handler.WriteToken(securityToken);

            // Act
            var tokenInfo = token.GetTokenInfo();

            // Assert
            Assert.Contains("name", tokenInfo);
            Assert.Equal("Test User", tokenInfo["name"]);
            Assert.Contains("role", tokenInfo);
            Assert.Equal("Admin", tokenInfo["role"]);
            Assert.Contains("alg", tokenInfo); // Algorithm in header
        }

        [Fact]
        public void GetTokenInfo_ShouldReturnEmptyDictionaryForInvalidToken()
        {
            // Arrange
            string invalidToken = "invalid.token";

            // Act
            var task = () => invalidToken.GetTokenInfo();

            // Assert
            task.Should().ThrowExactly<SecurityTokenMalformedException>();
        }

        [Fact]
        public void GetTokenInfo_ShouldHandleNullOrEmptyToken()
        {
            // Arrange
            string? nullToken = null;
            string emptyToken = "";

            // Act
            var nullTokenInfoAction = () => nullToken.GetTokenInfo();
            var emptyTokenInfoAction = () => emptyToken.GetTokenInfo();

            // Assert
            nullTokenInfoAction.Should().Throw<ArgumentNullException>();
            emptyTokenInfoAction.Should().Throw<ArgumentNullException>();
        }
    }
}
