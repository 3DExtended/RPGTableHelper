using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;
using RPGTableHelper.Shared.Extensions;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.ApiKeys
{
    public class RevokeApiKeyQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_RevokesKeySuccessfully()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var apiKeyId = Guid.NewGuid();

            var user = new UserEntity { Id = userId, Username = "Test" };
            Context.Users.Add(user);

            var entity = new ApiKeyEntity
            {
                Id = apiKeyId,
                UserId = userId,
                Name = "Test Key",
                Prefix = "sk-test",
                KeyHash = "hash",
                CreationDate = SystemClock.Now
            };
            Context.ApiKeys.Add(entity);
            await Context.SaveChangesAsync();

            var query = new RevokeApiKeyQuery { UserId = User.UserIdentifier.From(userId), ApiKeyId = apiKeyId };
            var handler = new RevokeApiKeyQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().BeTrue();

            Context.ChangeTracker.Clear();
            var dbEntity = await Context.ApiKeys.FindAsync(apiKeyId);
            dbEntity.RevokedAt.Should().NotBeNull();
            AssertCorrectTime(dbEntity.RevokedAt!.Value);
        }

        [Fact]
        public async Task RunQueryAsync_ReturnsFalse_WhenKeyNotFound()
        {
            // Arrange
            var query = new RevokeApiKeyQuery { UserId = User.UserIdentifier.From(Guid.NewGuid()), ApiKeyId = Guid.NewGuid() };
            var handler = new RevokeApiKeyQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().BeFalse();
        }
    }
}
