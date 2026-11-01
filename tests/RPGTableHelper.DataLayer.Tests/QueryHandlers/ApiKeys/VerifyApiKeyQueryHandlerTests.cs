using System.Security.Cryptography;
using System.Text;
using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;
using RPGTableHelper.Shared.Auth;
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
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().NotBeNull();
            result.Get()!.User.Username.Should().Be("TestUser");
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsNone_WhenKeyIsInvalid()
        {
            // Arrange
            var query = new VerifyApiKeyQuery { PlainApiKey = "sk-invalid-key" };
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

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
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsNone.Should().BeTrue();
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsScopesKeyIdAndPrefix_WhenKeyIsValid()
        {
            // Arrange
            var (plainKey, apiKeyEntity) = await CreateKeyAsync(
                scopes: "notes:read notes:write",
                expiresAt: null,
                lastUsedAt: null
            );
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(new VerifyApiKeyQuery { PlainApiKey = plainKey }, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().ApiKeyId.Should().Be(apiKeyEntity.Id);
            result.Get().Prefix.Should().Be(apiKeyEntity.Prefix);
            result.Get().Scopes.Should().Equal(ApiKeyScopes.NotesRead, ApiKeyScopes.NotesWrite);
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsNone_WhenKeyIsExpired()
        {
            // Arrange
            var (plainKey, _) = await CreateKeyAsync(
                scopes: "notes:read",
                expiresAt: SystemClock.Now.AddSeconds(-1),
                lastUsedAt: null
            );
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(new VerifyApiKeyQuery { PlainApiKey = plainKey }, CancellationToken.None);

            // Assert
            result.IsNone.Should().BeTrue();
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsKey_WhenExpiryLiesInTheFuture()
        {
            // Arrange
            var (plainKey, _) = await CreateKeyAsync(
                scopes: "notes:read",
                expiresAt: SystemClock.Now.AddDays(1),
                lastUsedAt: null
            );
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(new VerifyApiKeyQuery { PlainApiKey = plainKey }, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
        }

        [Fact]
        public async Task RunQueryAsync_SetsLastUsedAt_WhenNeverUsedBefore()
        {
            // Arrange
            var (plainKey, apiKeyEntity) = await CreateKeyAsync(scopes: "notes:read", expiresAt: null, lastUsedAt: null);
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            await handler.RunQueryAsync(new VerifyApiKeyQuery { PlainApiKey = plainKey }, CancellationToken.None);

            // Assert
            using var context = ContextFactory.CreateDbContext();
            var reloaded = context.ApiKeys.Single(k => k.Id == apiKeyEntity.Id);
            reloaded.LastUsedAt.Should().Be(SystemClock.Now);
        }

        [Fact]
        public async Task RunQueryAsync_DoesNotRewriteLastUsedAt_WithinTheUpdateInterval()
        {
            // Arrange
            var recentUse = SystemClock.Now.AddSeconds(-10);
            var (plainKey, apiKeyEntity) = await CreateKeyAsync(scopes: "notes:read", expiresAt: null, lastUsedAt: recentUse);
            var handler = new VerifyApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            await handler.RunQueryAsync(new VerifyApiKeyQuery { PlainApiKey = plainKey }, CancellationToken.None);

            // Assert
            using var context = ContextFactory.CreateDbContext();
            var reloaded = context.ApiKeys.Single(k => k.Id == apiKeyEntity.Id);
            reloaded.LastUsedAt.Should().Be(recentUse);
        }

        private async Task<(string PlainKey, ApiKeyEntity Entity)> CreateKeyAsync(
            string scopes,
            DateTimeOffset? expiresAt,
            DateTimeOffset? lastUsedAt
        )
        {
            var userId = Guid.NewGuid();
            Context.Users.Add(new UserEntity { Id = userId, Username = $"User{userId:N}" });

            var plainKey = $"sk-{Guid.NewGuid():N}";
            using var sha256 = SHA256.Create();
            var hash = Convert.ToBase64String(sha256.ComputeHash(Encoding.UTF8.GetBytes(plainKey)));

            var apiKeyEntity = new ApiKeyEntity
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Name = "Key",
                Prefix = plainKey.Substring(0, 7),
                KeyHash = hash,
                Scopes = scopes,
                ExpiresAt = expiresAt,
                LastUsedAt = lastUsedAt,
            };
            Context.ApiKeys.Add(apiKeyEntity);
            await Context.SaveChangesAsync();
            return (plainKey, apiKeyEntity);
        }
    }
}
