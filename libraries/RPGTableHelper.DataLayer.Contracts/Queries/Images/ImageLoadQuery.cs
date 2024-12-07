using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Images;

public class ImageLoadQuery : IQuery<Stream, ImageLoadQuery>
{
    public ImageMetaData MetaData { get; set; } = default!;
}
