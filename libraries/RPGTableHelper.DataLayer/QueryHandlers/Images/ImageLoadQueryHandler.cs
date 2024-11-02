using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;

namespace RPGTableHelper.DataLayer.QueryHandlers.Images;

public class ImageLoadQueryHandler : IQueryHandler<ImageLoadQuery, Stream>
{
    public IQueryHandler<ImageLoadQuery, Stream> Successor { get; set; } = default!;

    public Task<Option<Stream>> RunQueryAsync(ImageLoadQuery query, CancellationToken cancellationToken)
    {
        if (!query.MetaData.LocallyStored)
        {
            throw new NotImplementedException();
        }

        var filepath = "./userimages/" + query.MetaData.Id.Value.ToString().ToLower();

        filepath += query.MetaData.ImageType switch
        {
            Contracts.Models.Images.ImageType.JPEG => ".jpeg",
            Contracts.Models.Images.ImageType.PNG => ".png",
            _ => throw new NotImplementedException(),
        };

#pragma warning disable S2930 // "IDisposables" should be disposed
        FileStream stream = File.Open(filepath, FileMode.Open);
#pragma warning restore S2930 // "IDisposables" should be disposed

        return Task.FromResult(Option.From((Stream)stream));
    }
}
