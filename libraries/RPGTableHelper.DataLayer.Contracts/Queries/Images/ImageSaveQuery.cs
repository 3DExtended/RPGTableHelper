using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Images;

public class ImageSaveQuery : IQuery<Unit, ImageSaveQuery>
{
    public ImageMetaData MetaData { get; set; } = default!;
    public Stream Stream { get; set; } = default!;
}
