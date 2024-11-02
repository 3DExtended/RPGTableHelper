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
    public class ImageMetaDataQueryHandler
        : SingleModelQueryHandlerBase<
            ImageMetaDataQuery,
            ImageMetaData,
            ImageMetaData.ImageMetaDataIdentifier,
            Guid,
            RpgDbContext,
            ImageMetaDataEntity
        >
    {
        public ImageMetaDataQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }
    }
}
