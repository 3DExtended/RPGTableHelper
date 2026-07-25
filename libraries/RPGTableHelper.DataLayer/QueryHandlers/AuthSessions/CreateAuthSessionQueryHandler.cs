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
    public class CreateAuthSessionQueryHandler : IQueryHandler<CreateAuthSessionQuery, CreateAuthSessionResponse>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public CreateAuthSessionQueryHandler(IDbContextFactory<RpgDbContext> contextFactory, ISystemClock systemClock)
        {
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<CreateAuthSessionQuery, CreateAuthSessionResponse> Successor { get; set; } = default!;

        public async Task<Option<CreateAuthSessionResponse>> RunQueryAsync(
            CreateAuthSessionQuery query,
            CancellationToken cancellationToken
        )
        {
            var bytes = new byte[32];
            RandomNumberGenerator.Fill(bytes);
            var plainRefreshToken = Convert.ToBase64String(bytes)
                .Replace("+", string.Empty)
                .Replace("/", string.Empty)
                .Replace("=", string.Empty);

            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainRefreshToken));
            var hash = Convert.ToBase64String(hashBytes);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var entity = new AuthSessionEntity
            {
                Id = Guid.NewGuid(),
                UserId = query.UserId.Value,
                TokenHash = hash,
                ExpiresAt = query.ExpiresAt,
                CreationDate = _clock.Now,
                LastModifiedAt = _clock.Now,
            };

            context.AuthSessions.Add(entity);
            await context.SaveChangesAsync(cancellationToken);

            return Option.From(
                new CreateAuthSessionResponse
                {
                    AuthSessionId = entity.Id,
                    PlainRefreshToken = plainRefreshToken,
                    ExpiresAt = entity.ExpiresAt,
                }
            );
        }
    }
}
