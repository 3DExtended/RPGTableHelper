using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Images
{
    public class ImageMetaDataCreateQuery
        : CreateQuery<ImageMetaData, ImageMetaData.ImageMetaDataIdentifier, Guid, ImageMetaDataCreateQuery> { }
}
