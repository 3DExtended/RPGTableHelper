using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.AuthSessions;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.AuthSessions
{
    public class RevokeAllAuthSessionsForUserQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_RevokesAllLiveSessionsForUser_AndReturnsCount()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var otherUserId = Guid.NewGuid();

            Context.Users.AddRange(
                new UserEntity { Id = userId, Username = "Test" },
                new UserEntity { Id = otherUserId, Username = "Other" }
            );

            var sessionAId = Guid.NewGuid();
            var sessionBId = Guid.NewGuid();
            var alreadyRevokedSessionId = Guid.NewGuid();
            var otherUserSessionId = Guid.NewGuid();

            Context.AuthSessions.AddRange(
                new AuthSessionEntity
                {
                    Id = sessionAId,
                    UserId = userId,
                    TokenHash = "hashA",
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                },
                new AuthSessionEntity
                {
                    Id = sessionBId,
                    UserId = userId,
                    TokenHash = "hashB",
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                },
                new AuthSessionEntity
                {
                    Id = alreadyRevokedSessionId,
                    UserId = userId,
                    TokenHash = "hashC",
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                    RevokedAt = SystemClockNow.AddSeconds(-10),
                },
                new AuthSessionEntity
                {
                    Id = otherUserSessionId,
                    UserId = otherUserId,
                    TokenHash = "hashD",
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAllAuthSessionsForUserQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAllAuthSessionsForUserQuery { UserId = User.UserIdentifier.From(userId) },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().Be(2); // sessionA + sessionB, not the already-revoked one

            Context.ChangeTracker.Clear();
            var sessions = Context.AuthSessions.ToList();
            sessions.Single(s => s.Id == sessionAId).RevokedAt.Should().Be(SystemClockNow);
            sessions.Single(s => s.Id == sessionBId).RevokedAt.Should().Be(SystemClockNow);
            sessions.Single(s => s.Id == alreadyRevokedSessionId).RevokedAt.Should().Be(SystemClockNow.AddSeconds(-10));
            sessions.Single(s => s.Id == otherUserSessionId).RevokedAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_NoSessionsForUser_ReturnsZero()
        {
            // Arrange
            var handler = new RevokeAllAuthSessionsForUserQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAllAuthSessionsForUserQuery { UserId = User.UserIdentifier.From(Guid.NewGuid()) },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().Be(0);
        }
    }
}
