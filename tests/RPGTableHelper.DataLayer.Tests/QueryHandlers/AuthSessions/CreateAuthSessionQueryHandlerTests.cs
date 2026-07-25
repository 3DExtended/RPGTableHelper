using FluentAssertions;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.AuthSessions;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.AuthSessions
{
    public class CreateAuthSessionQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_CreatesAuthSessionSuccessfully()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var user = new UserEntity { Id = userId, Username = "Test" };
            Context.Users.Add(user);
            await Context.SaveChangesAsync();

            var expiresAt = SystemClockNow.AddSeconds(7776000);

            var query = new CreateAuthSessionQuery
            {
                UserId = User.UserIdentifier.From(userId),
                ExpiresAt = expiresAt,
            };
            var handler = new CreateAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(query, CancellationToken.None);

            // Assert
            result.IsSome.Should().BeTrue();
            var response = result.Get();
            response.PlainRefreshToken.Should().NotBeNullOrEmpty();
            response.ExpiresAt.Should().Be(expiresAt);

            var entities = Context.AuthSessions.ToList();
            entities.Should().HaveCount(1);
            entities[0].UserId.Should().Be(userId);
            entities[0].ExpiresAt.Should().Be(expiresAt);
            entities[0].TokenHash.Should().NotBeNullOrEmpty();
            entities[0].TokenHash.Should().NotBe(response.PlainRefreshToken);
        }
    }
}
