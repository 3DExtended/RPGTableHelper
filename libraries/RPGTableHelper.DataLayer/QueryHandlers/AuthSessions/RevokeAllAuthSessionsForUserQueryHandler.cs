using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.AuthSessions
{
    public class RevokeAllAuthSessionsForUserQueryHandler
        : IQueryHandler<RevokeAllAuthSessionsForUserQuery, int>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public RevokeAllAuthSessionsForUserQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
        {
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<RevokeAllAuthSessionsForUserQuery, int> Successor { get; set; } = default!;

        public async Task<Option<int>> RunQueryAsync(
            RevokeAllAuthSessionsForUserQuery query,
            CancellationToken cancellationToken
        )
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var sessions = await context
                .AuthSessions.Where(s => s.UserId == query.UserId.Value && s.RevokedAt == null)
                .ToListAsync(cancellationToken);

            var now = _clock.Now;
            foreach (var session in sessions)
            {
                session.RevokedAt = now;
            }

            await context.SaveChangesAsync(cancellationToken);

            return Option.From(sessions.Count);
        }
    }
}
