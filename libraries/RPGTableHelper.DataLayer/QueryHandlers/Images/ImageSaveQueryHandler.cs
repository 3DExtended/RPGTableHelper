using System.Diagnostics;
using Microsoft.Extensions.Hosting;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;

namespace RPGTableHelper.DataLayer.QueryHandlers.Images;

public class ImageSaveQueryHandler : IQueryHandler<ImageSaveQuery, Unit>
{
    private readonly IHostEnvironment _hostEnvironment;

    public IQueryHandler<ImageSaveQuery, Unit> Successor { get; set; } = default!;

    public ImageSaveQueryHandler(IHostEnvironment hostEnvironment)
    {
        _hostEnvironment = hostEnvironment;
    }

    public async Task<Option<Unit>> RunQueryAsync(ImageSaveQuery query, CancellationToken cancellationToken)
    {
        if (!query.MetaData.LocallyStored)
        {
            throw new NotImplementedException();
        }

        var pathPart = "/app/database/userimages/"; // mounting point from docker compose
        if (_hostEnvironment.IsEnvironment("E2ETest") || Debugger.IsAttached)
        {
            pathPart = "./userimages/";
        }

        var filepath = pathPart + query.MetaData.Id.Value.ToString().ToLower();

        filepath += query.MetaData.ImageType switch
        {
            Contracts.Models.Images.ImageType.JPEG => ".jpeg",
            Contracts.Models.Images.ImageType.PNG => ".png",
            _ => throw new NotImplementedException(),
        };

        Directory.CreateDirectory(pathPart);

        using (var fileStream = File.Create(filepath))
        {
            if (query.Stream.CanSeek)
            {
                query.Stream.Seek(0, SeekOrigin.Begin);
            }

            await query.Stream.CopyToAsync(fileStream, cancellationToken).ConfigureAwait(false);
        }

        return Unit.Value;
    }
}
