using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.Images;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.ImageMetaDatas
{
    public class ImageMetaDatasQueryHandler
        : ListOfModelQueryHandlerBase<
            ImageMetaDatasQuery,
            ImageMetaData,
            ImageMetaData.ImageMetaDataIdentifier,
            Guid,
            RpgDbContext,
            ImageMetaDataEntity
        >
    {
        public ImageMetaDatasQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }

        protected override IQueryable<ImageMetaDataEntity> AddWhere(
            IQueryable<ImageMetaDataEntity> queryable,
            ImageMetaDatasQuery query
        )
        {
            return queryable
                .Where(e => e.CreatedForCampagneId == query.CampagneIdentifier.Value)
                .Where(e => e.CreatorId == query.RequestingUserIdentifier.Value);
        }
    }
}
