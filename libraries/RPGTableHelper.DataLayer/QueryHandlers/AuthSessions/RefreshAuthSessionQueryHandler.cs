using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.AuthSessions;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.AuthSessions
{
    public class RefreshAuthSessionQueryHandler : IQueryHandler<RefreshAuthSessionQuery, RefreshAuthSessionResponse>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public RefreshAuthSessionQueryHandler(IDbContextFactory<RpgDbContext> contextFactory, ISystemClock systemClock)
        {
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<RefreshAuthSessionQuery, RefreshAuthSessionResponse> Successor { get; set; } = default!;

        public async Task<Option<RefreshAuthSessionResponse>> RunQueryAsync(
            RefreshAuthSessionQuery query,
            CancellationToken cancellationToken
        )
        {
            var now = _clock.Now;
            var presentedHash = HashToken(query.PlainRefreshToken);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var currentMatch = await context
                .AuthSessions.Where(s => s.TokenHash == presentedHash)
                .SingleOrDefaultAsync(cancellationToken);

            if (currentMatch != null)
            {
                if (currentMatch.RevokedAt != null || currentMatch.ExpiresAt < now)
                {
                    // known but dead session: expired or already revoked. No side effects.
                    return Option.None;
                }

                return Option.From(await RotateAsync(context, currentMatch, now, query, cancellationToken));
            }

            var previousMatch = await context
                .AuthSessions.Where(s => s.PreviousTokenHash == presentedHash)
                .SingleOrDefaultAsync(cancellationToken);

            if (previousMatch != null)
            {
                if (previousMatch.RevokedAt != null)
                {
                    return Option.None;
                }

                if (previousMatch.PreviousTokenExpiresAt.HasValue && previousMatch.PreviousTokenExpiresAt.Value >= now)
                {
                    // still within the rotation grace window: treat as another legitimate refresh.
                    return Option.From(await RotateAsync(context, previousMatch, now, query, cancellationToken));
                }

                // reuse of a rotated-away token after its grace window: likely theft. Kill this
                // session chain only, leave the user's other sessions untouched.
                previousMatch.RevokedAt = now;
                await context.SaveChangesAsync(cancellationToken);
                return Option.None;
            }

            // unknown token entirely: no side effects.
            return Option.None;
        }

        private static async Task<RefreshAuthSessionResponse> RotateAsync(
            RpgDbContext context,
            AuthSessionEntity session,
            DateTimeOffset now,
            RefreshAuthSessionQuery query,
            CancellationToken cancellationToken
        )
        {
            var (plainToken, hash) = GenerateTokenAndHash();

            session.PreviousTokenHash = session.TokenHash;
            session.PreviousTokenExpiresAt = now.AddSeconds(query.GracePeriodSeconds);
            session.TokenHash = hash;
            session.ExpiresAt = now.AddSeconds(query.NewRefreshTokenLifetimeSeconds);
            session.RevokedAt = null;

            await context.SaveChangesAsync(cancellationToken);

            return new RefreshAuthSessionResponse
            {
                UserId = session.UserId,
                PlainRefreshToken = plainToken,
                ExpiresAt = session.ExpiresAt,
            };
        }

        private static (string plain, string hash) GenerateTokenAndHash()
        {
            var bytes = new byte[32];
            RandomNumberGenerator.Fill(bytes);
            var plain = Convert.ToBase64String(bytes).Replace("+", string.Empty).Replace("/", string.Empty).Replace("=", string.Empty);

            return (plain, HashToken(plain));
        }

        private static string HashToken(string plainToken)
        {
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainToken));
            return Convert.ToBase64String(hashBytes);
        }
    }
}
