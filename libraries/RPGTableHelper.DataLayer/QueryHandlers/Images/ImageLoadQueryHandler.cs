using System.Diagnostics;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;

namespace RPGTableHelper.DataLayer.QueryHandlers.Images;

public class ImageLoadQueryHandler : IQueryHandler<ImageLoadQuery, Stream>
{
    private readonly IHostEnvironment _hostEnvironment;
    private readonly ILogger<ImageLoadQueryHandler> _logger;

    public IQueryHandler<ImageLoadQuery, Stream> Successor { get; set; } = default!;

    public ImageLoadQueryHandler(IHostEnvironment hostEnvironment, ILogger<ImageLoadQueryHandler> logger)
    {
        _hostEnvironment = hostEnvironment;
        _logger = logger;
    }

    public async Task<Option<Stream>> RunQueryAsync(ImageLoadQuery query, CancellationToken cancellationToken)
    {
        if (!query.MetaData.LocallyStored)
        {
            throw new NotImplementedException();
        }

        var filepath =
            "/app/database/userimages/" // mounting point from docker compose
            + query.MetaData.Id.Value.ToString().ToLower();

        if (_hostEnvironment.IsEnvironment("E2ETest") || Debugger.IsAttached)
        {
            filepath = "./userimages/" + query.MetaData.Id.Value.ToString().ToLower();
        }

        filepath += query.MetaData.ImageType switch
        {
            Contracts.Models.Images.ImageType.JPEG => ".jpeg",
            Contracts.Models.Images.ImageType.PNG => ".png",
            _ => throw new NotImplementedException(),
        };

        if (!File.Exists(filepath))
        {
            // metadata without a file means the image was lost on disk (e.g. storage moved or wiped)
            _logger.LogWarning(
                "Image file {FilePath} for image metadata {ImageId} does not exist",
                filepath,
                query.MetaData.Id.Value
            );
            return Option<Stream>.None;
        }

        var retryCounter = 0;
        Exception? lastException = null;

        while (retryCounter < 5)
        {
            retryCounter++;
            try
            {
                // read-only + shared so concurrent requests for the same image don't lock each other out
#pragma warning disable S2930 // "IDisposables" should be disposed
                FileStream stream = File.Open(filepath, FileMode.Open, FileAccess.Read, FileShare.Read);
#pragma warning restore S2930 // "IDisposables" should be disposed

                return Option.From((Stream)stream);
            }
            catch (IOException ex)
            {
                // can be ignored since the app will try again later
                lastException = ex;
            }

            await Task.Delay(100);
        }

        _logger.LogWarning(lastException, "Could not open image file {FilePath} after {Retries} attempts", filepath, retryCounter);

        return Option<Stream>.None;
    }
}
