using FluentAssertions;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Extensions;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.ApiKeys
{
    public class CreateApiKeyQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_CreatesApiKeySuccessfully()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var user = new UserEntity { Id = userId, Username = "Test" };
            Context.Users.Add(user);
            await Context.SaveChangesAsync();

            var query = new CreateApiKeyQuery
            {
                UserId = User.UserIdentifier.From(userId),
                Name = "Test Key"
            };
            var handler = new CreateApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            var response = result.Get();
            response.PlainKey.Should().StartWith("sk-");
            response.ApiKey.Should().NotBeNull();
            response.ApiKey.Name.Should().Be("Test Key");

            var entities = Context.ApiKeys.ToList();
            entities.Should().HaveCount(1);
            entities[0].UserId.Should().Be(userId);
            entities[0].Name.Should().Be("Test Key");
            entities[0].KeyHash.Should().NotBeNullOrEmpty();
            entities[0].Prefix.Should().Be(response.PlainKey.Substring(0, 7));
        }

        [Fact]
        public async Task RunQueryAsync_StoresScopesAndExpiry_AndReturnsThemOnTheDto()
        {
            // Arrange
            var userId = Guid.NewGuid();
            Context.Users.Add(new UserEntity { Id = userId, Username = "Scoped" });
            await Context.SaveChangesAsync();

            var expiresAt = SystemClock.Now.AddDays(30);
            var query = new CreateApiKeyQuery
            {
                UserId = User.UserIdentifier.From(userId),
                Name = "Companion app",
                Scopes = new[] { ApiKeyScopes.NotesWrite, ApiKeyScopes.CampaignsRead, "unknown:scope" },
                ExpiresAt = Option.From(expiresAt),
            };
            var handler = new CreateApiKeyQueryHandler(Mapper, ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.Get().ApiKey.Scopes.Should().Equal(ApiKeyScopes.CampaignsRead, ApiKeyScopes.NotesWrite);
            result.Get().ApiKey.ExpiresAt.Should().Be(expiresAt);
            result.Get().ApiKey.CreatedAt.Should().Be(SystemClock.Now);

            var entity = Context.ApiKeys.Single();
            entity.Scopes.Should().Be("campaigns:read notes:write");
            entity.ExpiresAt.Should().Be(expiresAt);
            entity.LastUsedAt.Should().BeNull();
        }
    }
}
