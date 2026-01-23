using System.Security.Cryptography;
using System.Text;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.ApiKeys
{
    public class CreateApiKeyQueryHandler : IQueryHandler<CreateApiKeyQuery, CreateApiKeyResponse>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public CreateApiKeyQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<CreateApiKeyQuery, CreateApiKeyResponse> Successor { get; set; } = default!;

        public async Task<Option<CreateApiKeyResponse>> RunQueryAsync(CreateApiKeyQuery query, CancellationToken cancellationToken)
        {
            // Generate Key
            var bytes = new byte[32];
            RandomNumberGenerator.Fill(bytes);
            // URL-safe base64 logic or just hex? Plan said "sk-" prefix.
            // Using standard Base64 replaces
            var baseKey = Convert.ToBase64String(bytes)
                .Replace("+", string.Empty)
                .Replace("/", string.Empty)
                .Replace("=", string.Empty)
                .Substring(0, 32);

            var plainKey = $"sk-{baseKey}";

            // Hash
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainKey));
            var hash = Convert.ToBase64String(hashBytes);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var entity = new ApiKeyEntity
            {
                Id = Guid.NewGuid(),
                UserId = query.UserId.Value,
                Name = query.Name,
                Prefix = plainKey.Substring(0, 7),
                KeyHash = hash,
                CreationDate = _clock.Now, // Base prop
                LastModifiedAt = _clock.Now // Base prop
            };

            context.ApiKeys.Add(entity);
            await context.SaveChangesAsync(cancellationToken);

            var dto = _mapper.Map<ApiKeyDto>(entity);
            return Option.From(new CreateApiKeyResponse
            {
                ApiKey = dto,
                PlainKey = plainKey
            });
        }
    }
}
