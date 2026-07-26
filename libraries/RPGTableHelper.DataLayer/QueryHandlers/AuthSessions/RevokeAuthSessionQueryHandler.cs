using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.AuthSessions
{
    public class RevokeAuthSessionQueryHandler : IQueryHandler<RevokeAuthSessionQuery, bool>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public RevokeAuthSessionQueryHandler(IDbContextFactory<RpgDbContext> contextFactory, ISystemClock systemClock)
        {
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<RevokeAuthSessionQuery, bool> Successor { get; set; } = default!;

        public async Task<Option<bool>> RunQueryAsync(RevokeAuthSessionQuery query, CancellationToken cancellationToken)
        {
            var hash = HashToken(query.PlainRefreshToken);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var session = await context
                .AuthSessions.Where(s => s.TokenHash == hash || s.PreviousTokenHash == hash)
                .SingleOrDefaultAsync(cancellationToken);

            if (session == null)
            {
                return Option.None;
            }

            session.RevokedAt = _clock.Now;
            session.PreviousTokenHash = null;
            session.PreviousTokenExpiresAt = null;

            await context.SaveChangesAsync(cancellationToken);

            return Option.From(true);
        }

        private static string HashToken(string plainToken)
        {
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainToken));
            return Convert.ToBase64String(hashBytes);
        }
    }
}
