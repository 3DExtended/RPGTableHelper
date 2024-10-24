using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests
{
    public class OpenSignInProviderRegisterRequestExistsByApiKeyQueryHandler
        : IQueryHandler<
            OpenSignInProviderRegisterRequestExistsByApiKeyQuery,
            OpenSignInProviderRegisterRequest
        >
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly IMapper _mapper;

        public OpenSignInProviderRegisterRequestExistsByApiKeyQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            IMapper mapper
        )
        {
            _contextFactory = contextFactory;
            _mapper = mapper;
        }

        public IQueryHandler<
            OpenSignInProviderRegisterRequestExistsByApiKeyQuery,
            OpenSignInProviderRegisterRequest
        > Successor { get; set; } = default!;

        public async Task<Option<OpenSignInProviderRegisterRequest>> RunQueryAsync(
            OpenSignInProviderRegisterRequestExistsByApiKeyQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
            {
                var entity = await context
                    .Set<OpenSignInProviderRegisterRequestEntity>()
                    .Where((e) => e.ExposedApiKey == query.ApiKey)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                {
                    return Option.None;
                }

                return _mapper.Map<OpenSignInProviderRegisterRequest>(entity);
            }
        }
    }
}
