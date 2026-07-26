using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.AuthSessions;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.AuthSessions
{
    public class RevokeAuthSessionQueryHandlerTests : QueryHandlersTestBase
    {
        [Fact]
        public async Task RunQueryAsync_MatchingCurrentToken_RevokesSessionAndClearsPreviousHash()
        {
            // Arrange
            var (plainToken, hash) = CreatePlainAndHash();
            var userId = Guid.NewGuid();

            Context.Users.Add(new UserEntity { Id = userId, Username = "Test" });
            Context.AuthSessions.Add(
                new AuthSessionEntity
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    TokenHash = hash,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                    PreviousTokenHash = "some-stale-previous-hash",
                    PreviousTokenExpiresAt = SystemClockNow.AddSeconds(60),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAuthSessionQuery { PlainRefreshToken = plainToken },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            result.Get().Should().BeTrue();

            Context.ChangeTracker.Clear();
            var entity = Context.AuthSessions.Single();
            entity.RevokedAt.Should().Be(SystemClockNow);
            entity.PreviousTokenHash.Should().BeNull();
            entity.PreviousTokenExpiresAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_MatchingPreviousToken_RevokesSession()
        {
            // Arrange: client still holds the just-rotated-away token (e.g. logout
            // fired right after a refresh raced it), which should still identify
            // and revoke the session.
            var (previousPlainToken, previousHash) = CreatePlainAndHash();
            var (_, currentHash) = CreatePlainAndHash();
            var userId = Guid.NewGuid();

            Context.Users.Add(new UserEntity { Id = userId, Username = "Test" });
            Context.AuthSessions.Add(
                new AuthSessionEntity
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    TokenHash = currentHash,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                    PreviousTokenHash = previousHash,
                    PreviousTokenExpiresAt = SystemClockNow.AddSeconds(60),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAuthSessionQuery { PlainRefreshToken = previousPlainToken },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            Context.ChangeTracker.Clear();
            var entity = Context.AuthSessions.Single();
            entity.RevokedAt.Should().Be(SystemClockNow);
            entity.PreviousTokenHash.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_UnknownToken_ReturnsNoneWithoutSideEffects()
        {
            // Arrange
            var (_, hash) = CreatePlainAndHash();
            var userId = Guid.NewGuid();
            Context.Users.Add(new UserEntity { Id = userId, Username = "Test" });
            Context.AuthSessions.Add(
                new AuthSessionEntity
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    TokenHash = hash,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAuthSessionQuery { PlainRefreshToken = "totally-unknown-token" },
                CancellationToken.None
            );

            // Assert
            result.IsNone.Should().BeTrue();
            Context.ChangeTracker.Clear();
            Context.AuthSessions.Single().RevokedAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_AlreadyRevokedSession_StaysRevokedAndSucceeds()
        {
            // Arrange: logout is idempotent - revoking an already-revoked session
            // should not throw and should still report success.
            var (plainToken, hash) = CreatePlainAndHash();
            var userId = Guid.NewGuid();
            Context.Users.Add(new UserEntity { Id = userId, Username = "Test" });
            Context.AuthSessions.Add(
                new AuthSessionEntity
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    TokenHash = hash,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                    RevokedAt = SystemClockNow.AddSeconds(-10),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAuthSessionQuery { PlainRefreshToken = plainToken },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            Context.ChangeTracker.Clear();
            Context.AuthSessions.Single().RevokedAt.Should().Be(SystemClockNow);
        }

        [Fact]
        public async Task RunQueryAsync_TwoSessionsForSameUser_OnlyMatchingSessionIsRevoked()
        {
            // Arrange
            var (plainTokenA, hashA) = CreatePlainAndHash();
            var (_, hashB) = CreatePlainAndHash();
            var userId = Guid.NewGuid();
            var sessionAId = Guid.NewGuid();
            var sessionBId = Guid.NewGuid();

            Context.Users.Add(new UserEntity { Id = userId, Username = "Test" });
            Context.AuthSessions.AddRange(
                new AuthSessionEntity
                {
                    Id = sessionAId,
                    UserId = userId,
                    TokenHash = hashA,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                },
                new AuthSessionEntity
                {
                    Id = sessionBId,
                    UserId = userId,
                    TokenHash = hashB,
                    ExpiresAt = SystemClockNow.AddSeconds(7776000),
                }
            );
            await Context.SaveChangesAsync();

            var handler = new RevokeAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RevokeAuthSessionQuery { PlainRefreshToken = plainTokenA },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            Context.ChangeTracker.Clear();
            var sessions = Context.AuthSessions.OrderBy(s => s.Id).ToList();
            sessions.Single(s => s.Id == sessionAId).RevokedAt.Should().NotBeNull();
            sessions.Single(s => s.Id == sessionBId).RevokedAt.Should().BeNull();
        }

        private static (string plain, string hash) CreatePlainAndHash()
        {
            var plain = Guid.NewGuid().ToString("N");
            using var sha256 = System.Security.Cryptography.SHA256.Create();
            var hashBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(plain));
            return (plain, Convert.ToBase64String(hashBytes));
        }
    }
}
