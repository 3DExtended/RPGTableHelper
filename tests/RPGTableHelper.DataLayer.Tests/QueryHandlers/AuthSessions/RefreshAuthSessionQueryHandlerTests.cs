using FluentAssertions;
using NSubstitute;
using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.AuthSessions;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.AuthSessions
{
    public class RefreshAuthSessionQueryHandlerTests : QueryHandlersTestBase
    {
        private const long RefreshLifetimeSeconds = 7776000; // 90 days
        private const long GracePeriodSeconds = 60;

        [Fact]
        public async Task RunQueryAsync_ValidCurrentToken_RotatesSessionAndReturnsNewToken()
        {
            // Arrange
            var (userId, plainToken) = await SeedUserAndSessionAsync();
            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            result.IsSome.Should().BeTrue();
            var response = result.Get();
            response.UserId.Should().Be(userId);
            response.PlainRefreshToken.Should().NotBeNullOrEmpty();
            response.PlainRefreshToken.Should().NotBe(plainToken);
            response.ExpiresAt.Should().Be(SystemClockNow.AddSeconds(RefreshLifetimeSeconds));

            var entity = Context.AuthSessions.Single();
            entity.TokenHash.Should().NotBe(HashOf(plainToken));
            entity.PreviousTokenHash.Should().Be(HashOf(plainToken));
            entity.PreviousTokenExpiresAt.Should().Be(SystemClockNow.AddSeconds(GracePeriodSeconds));
            entity.RevokedAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_PreviousTokenWithinGrace_RotatesAgainAndSucceeds()
        {
            // Arrange
            var (_, plainToken) = await SeedUserAndSessionAsync();
            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            var firstResult = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );
            firstResult.IsSome.Should().BeTrue();

            // Act: twin refresh using the OLD (pre-rotation) token, still within grace
            var secondResult = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            secondResult.IsSome.Should().BeTrue();
            secondResult.Get().PlainRefreshToken.Should().NotBe(firstResult.Get().PlainRefreshToken);

            var entities = Context.AuthSessions.ToList();
            entities.Should().HaveCount(1);
            entities[0].RevokedAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_PreviousTokenAfterGrace_RevokesSessionAndReturnsNone()
        {
            // Arrange
            var (_, plainToken) = await SeedUserAndSessionAsync();
            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            var firstResult = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );
            firstResult.IsSome.Should().BeTrue();

            // advance clock past the grace window
            SystemClock.Now.Returns(SystemClockNow.AddSeconds(GracePeriodSeconds + 5));

            // Act: reuse the OLD (pre-rotation) token, now after grace
            var secondResult = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            secondResult.IsNone.Should().BeTrue();

            var entity = Context.AuthSessions.Single();
            entity.RevokedAt.Should().Be(SystemClockNow.AddSeconds(GracePeriodSeconds + 5));
        }

        [Fact]
        public async Task RunQueryAsync_ExpiredCurrentToken_ReturnsNoneWithoutSideEffects()
        {
            // Arrange
            var (_, plainToken) = await SeedUserAndSessionAsync(expiresAt: SystemClockNow.AddSeconds(-10));
            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            result.IsNone.Should().BeTrue();

            var entity = Context.AuthSessions.Single();
            entity.RevokedAt.Should().BeNull();
            entity.TokenHash.Should().Be(HashOf(plainToken));
        }

        [Fact]
        public async Task RunQueryAsync_UnknownToken_ReturnsNoneWithoutSideEffects()
        {
            // Arrange
            await SeedUserAndSessionAsync();
            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = "totally-unknown-token",
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            result.IsNone.Should().BeTrue();
            Context.AuthSessions.Single().RevokedAt.Should().BeNull();
        }

        [Fact]
        public async Task RunQueryAsync_RevokedSessionReused_ReturnsNone()
        {
            // Arrange
            var (_, plainToken) = await SeedUserAndSessionAsync();
            var entity = Context.AuthSessions.Single();
            entity.RevokedAt = SystemClockNow;
            await Context.SaveChangesAsync();

            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            // Act
            var result = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainToken,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            result.IsNone.Should().BeTrue();
        }

        [Fact]
        public async Task RunQueryAsync_TwoSessionsForSameUser_ReuseOnOneDoesNotTouchOther()
        {
            // Arrange
            var userId = Guid.NewGuid();
            var (plainTokenA, hashA) = CreatePlainAndHash();
            var (_, hashB) = CreatePlainAndHash();
            var sessionAId = Guid.NewGuid();
            var sessionBId = Guid.NewGuid();

            using (var seedContext = ContextFactory.CreateDbContext())
            {
                seedContext.Users.Add(new UserEntity { Id = userId, Username = "Test" });
                seedContext.AuthSessions.AddRange(
                    new AuthSessionEntity
                    {
                        Id = sessionAId,
                        UserId = userId,
                        TokenHash = hashA,
                        ExpiresAt = SystemClockNow.AddSeconds(RefreshLifetimeSeconds),
                    },
                    new AuthSessionEntity
                    {
                        Id = sessionBId,
                        UserId = userId,
                        TokenHash = hashB,
                        ExpiresAt = SystemClockNow.AddSeconds(RefreshLifetimeSeconds),
                    }
                );
                await seedContext.SaveChangesAsync();
            }

            var handler = new RefreshAuthSessionQueryHandler(ContextFactory, SystemClock);

            // rotate session A once, then advance past grace and reuse plainTokenA to trigger a revoke
            await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainTokenA,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            SystemClock.Now.Returns(SystemClockNow.AddSeconds(GracePeriodSeconds + 5));

            // Act
            var reuseResult = await handler.RunQueryAsync(
                new RefreshAuthSessionQuery
                {
                    PlainRefreshToken = plainTokenA,
                    NewRefreshTokenLifetimeSeconds = RefreshLifetimeSeconds,
                    GracePeriodSeconds = GracePeriodSeconds,
                },
                CancellationToken.None
            );

            // Assert
            reuseResult.IsNone.Should().BeTrue();

            var sessions = Context.AuthSessions.OrderBy(s => s.Id).ToList();
            var reloadedA = sessions.Single(s => s.Id == sessionAId);
            var reloadedB = sessions.Single(s => s.Id == sessionBId);

            reloadedA.RevokedAt.Should().NotBeNull();
            reloadedB.RevokedAt.Should().BeNull();
            reloadedB.TokenHash.Should().Be(hashB);
        }

        private static (string plain, string hash) CreatePlainAndHash()
        {
            var plain = Guid.NewGuid().ToString("N");
            return (plain, HashOf(plain));
        }

        private static string HashOf(string plain)
        {
            using var sha256 = System.Security.Cryptography.SHA256.Create();
            var hashBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(plain));
            return Convert.ToBase64String(hashBytes);
        }

        private async Task<(Guid userId, string plainToken)> SeedUserAndSessionAsync(DateTimeOffset? expiresAt = null)
        {
            var userId = Guid.NewGuid();
            var (plainToken, hash) = CreatePlainAndHash();

            // Seed via a throwaway context so the shared `Context` never tracks these rows;
            // otherwise later `Context.AuthSessions...` reads would return stale, pre-rotation
            // in-memory state instead of hitting the (shared-cache sqlite) database.
            using (var seedContext = ContextFactory.CreateDbContext())
            {
                seedContext.Users.Add(new UserEntity { Id = userId, Username = "Test" });
                seedContext.AuthSessions.Add(
                    new AuthSessionEntity
                    {
                        Id = Guid.NewGuid(),
                        UserId = userId,
                        TokenHash = hash,
                        ExpiresAt = expiresAt ?? SystemClockNow.AddSeconds(RefreshLifetimeSeconds),
                    }
                );
                await seedContext.SaveChangesAsync();
            }

            return (userId, plainToken);
        }
    }
}
