using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes
{
    public class CampagneIsUserInCampagneQueryHandler
        : IQueryHandler<CampagneIsUserInCampagneQuery, bool>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public CampagneIsUserInCampagneQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
        {
            _contextFactory = contextFactory;
        }

        public IQueryHandler<CampagneIsUserInCampagneQuery, bool> Successor { get; set; } =
            default!;

        public async Task<Option<bool>> RunQueryAsync(
            CampagneIsUserInCampagneQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
            {
                var campagneWithUsers = await context
                    .Set<CampagneEntity>()
                    .Where((e) => e.Id == query.CampagneId.Value)
                    .Include(e => e.Characters)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (campagneWithUsers == null || campagneWithUsers.Characters == null)
                {
                    return Option.None;
                }

                return campagneWithUsers.DmUserId == query.UserIdToCheck.Value
                    || campagneWithUsers
                        .Characters!.Select(e => e.PlayerUserId)
                        .Contains(query.UserIdToCheck.Value);
            }
        }
    }
}
