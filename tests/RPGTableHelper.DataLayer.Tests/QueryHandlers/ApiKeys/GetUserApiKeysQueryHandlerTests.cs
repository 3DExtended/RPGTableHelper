using FluentAssertions;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;
using RPGTableHelper.Shared.Extensions;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.ApiKeys
{
    public class GetUserApiKeysQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_ReturnsUserKeys()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var otherUserId = Guid.NewGuid();

            var user1 = new UserEntity { Id = userId, Username = "User1" };
            var user2 = new UserEntity { Id = otherUserId, Username = "User2" };
            Context.Users.AddRange(user1, user2);

            var entity1 = new ApiKeyEntity { Id = Guid.NewGuid(), UserId = userId, Name = "Key 1", Prefix = "sk-1", KeyHash = "h1", CreationDate = SystemClock.Now };
            var entity2 = new ApiKeyEntity { Id = Guid.NewGuid(), UserId = userId, Name = "Key 2", Prefix = "sk-2", KeyHash = "h2", CreationDate = SystemClock.Now.AddMinutes(-5) };
            var entity3 = new ApiKeyEntity { Id = Guid.NewGuid(), UserId = otherUserId, Name = "Key 3", Prefix = "sk-3", KeyHash = "h3", CreationDate = SystemClock.Now };

            Context.ApiKeys.AddRange(entity1, entity2, entity3);
            await Context.SaveChangesAsync();

            var query = new GetUserApiKeysQuery { UserId = User.UserIdentifier.From(userId) };
            var handler = new GetUserApiKeysQueryHandler(Mapper, ContextFactory);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            var keys = result.Get().ToList();
            keys.Should().HaveCount(2);
            keys.Should().Contain(k => k.Name == "Key 1");
            keys.Should().Contain(k => k.Name == "Key 2");
            keys.Should().NotContain(k => k.Name == "Key 3");
        }
    }
}
