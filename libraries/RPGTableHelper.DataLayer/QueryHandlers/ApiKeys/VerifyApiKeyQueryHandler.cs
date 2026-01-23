using System.Security.Cryptography;
using System.Text;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.ApiKeys
{
    public class VerifyApiKeyQueryHandler : IQueryHandler<VerifyApiKeyQuery, User>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public VerifyApiKeyQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<VerifyApiKeyQuery, User> Successor { get; set; } = default!;

        public async Task<Option<User>> RunQueryAsync(VerifyApiKeyQuery query, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(query.PlainApiKey))
            {
                return Option.None;
            }

            // Hash the input key
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(query.PlainApiKey));
            var hash = Convert.ToBase64String(hashBytes);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var apiKeyEntity = await context.ApiKeys
                .Include(k => k.User)
                .AsNoTracking()
                .FirstOrDefaultAsync(k => k.KeyHash == hash, cancellationToken);

            if (apiKeyEntity == null || apiKeyEntity.RevokedAt.HasValue)
            {
                return Option.None;
            }

            // Return the associated User
            var userDto = _mapper.Map<User>(apiKeyEntity.User);
            return Option.From(userDto);
        }
    }
}
