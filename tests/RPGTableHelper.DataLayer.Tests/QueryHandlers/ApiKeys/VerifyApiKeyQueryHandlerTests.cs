using System.Security.Cryptography;
using System.Text;
using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;
using RPGTableHelper.Shared.Extensions;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.ApiKeys
{
    public class VerifyApiKeyQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_ReturnsUser_WhenKeyIsValid()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var userEntity = new UserEntity { Id = userId, Username = "TestUser" };
            Context.Users.Add(userEntity);

            var plainKey = "sk-valid-key";
            using var sha256 = SHA256.Create();
            var hash = Convert.ToBase64String(sha256.ComputeHash(Encoding.UTF8.GetBytes(plainKey)));

            var apiKeyEntity = new ApiKeyEntity
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Name = "Key",
                Prefix = "sk-valid",
                KeyHash = hash,
                CreationDate = SystemClock.Now
            };
            Context.ApiKeys.Add(apiKeyEntity);
            await Context.SaveChangesAsync();

            var query = new VerifyApiKeyQuery { PlainApiKey = plainKey };
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().NotBeNull();
            result.Get()!.Username.Should().Be("TestUser");
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsNone_WhenKeyIsInvalid()
        {
            // Arrange
            var query = new VerifyApiKeyQuery { PlainApiKey = "sk-invalid-key" };
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsNone.Should().BeTrue();
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsNone_WhenKeyIsRevoked()
        {
             // Arrange
            var userId = Guid.NewGuid();
            var userEntity = new UserEntity { Id = userId, Username = "TestUser" };
            Context.Users.Add(userEntity);

            var plainKey = "sk-revoked-key";
            using var sha256 = SHA256.Create();
            var hash = Convert.ToBase64String(sha256.ComputeHash(Encoding.UTF8.GetBytes(plainKey)));

            var apiKeyEntity = new ApiKeyEntity
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Name = "Key",
                Prefix = "sk-revok",
                KeyHash = hash,
                CreationDate = SystemClock.Now,
                RevokedAt = SystemClock.Now
            };
            Context.ApiKeys.Add(apiKeyEntity);
            await Context.SaveChangesAsync();

            var query = new VerifyApiKeyQuery { PlainApiKey = plainKey };
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsNone.Should().BeTrue();
        }
    }
}
