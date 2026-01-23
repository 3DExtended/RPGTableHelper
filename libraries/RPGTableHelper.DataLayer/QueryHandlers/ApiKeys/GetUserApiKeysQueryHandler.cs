using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.ApiKeys
{
    public class GetUserApiKeysQueryHandler : IQueryHandler<GetUserApiKeysQuery, IEnumerable<ApiKeyDto>>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public GetUserApiKeysQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<GetUserApiKeysQuery, IEnumerable<ApiKeyDto>> Successor { get; set; } = default!;

        public async Task<Option<IEnumerable<ApiKeyDto>>> RunQueryAsync(GetUserApiKeysQuery query, CancellationToken cancellationToken)
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var entities = await context.ApiKeys
                .Where(x => x.UserId == query.UserId.Value)
                .ToListAsync(cancellationToken);

            var dtos = entities
                .OrderByDescending(x => x.CreationDate)
                .Select(_mapper.Map<ApiKeyDto>)
                .ToList();

            return Option.From<IEnumerable<ApiKeyDto>>(dtos);
        }
    }
}
