using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Images
{
    public class ImageMetaDatasQuery
        : ListOfModelQuery<ImageMetaData, ImageMetaData.ImageMetaDataIdentifier, Guid, ImageMetaDatasQuery>
    {
        public Campagne.CampagneIdentifier CampagneIdentifier { get; set; } = default!;
        public User.UserIdentifier RequestingUserIdentifier { get; set; } = default!;
    }
}
