using System.ClientModel;

using Microsoft.Extensions.Logging;

using OpenAI;
using OpenAI.Images;

using Prodot.Patterns.Cqrs;

using RPGTableHelper.DataLayer.OpenAI.Contracts.Options;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;

namespace RPGTableHelper.DataLayer.OpenAI.QueryHandlers;

public class AiGenerateImageQueryHandler : IQueryHandler<AiGenerateImageQuery, Stream>
{
    private const string DefaultImageModel = "gpt-image-1";

    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<AiGenerateImageQueryHandler> _logger;
    private readonly OpenAIOptions _options;

    public AiGenerateImageQueryHandler(
        OpenAIOptions options,
        IHttpClientFactory httpClientFactory,
        ILogger<AiGenerateImageQueryHandler> logger
    )
    {
        _options = options;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public IQueryHandler<AiGenerateImageQuery, Stream> Successor { get; set; } = default!;

    public async Task<Option<Stream>> RunQueryAsync(AiGenerateImageQuery query, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(_options.ApiKey))
        {
            return Option.None;
        }

        var credential = new ApiKeyCredential(_options.ApiKey);
        OpenAIClient client = string.IsNullOrWhiteSpace(_options.OpenAIUrl)
            ? new OpenAIClient(credential)
            : new OpenAIClient(credential, new OpenAIClientOptions { Endpoint = new Uri(_options.OpenAIUrl) });

        var model = string.IsNullOrWhiteSpace(_options.ImageModel)
            ? DefaultImageModel
            : _options.ImageModel.Trim();
        var imageClient = client.GetImageClient(model);

        try
        {
            var imageGeneration = await imageClient
                .GenerateImageAsync(
                    query.ImagePrompt,
                    new ImageGenerationOptions()
                    {
                        Size = GeneratedImageSize.W1024xH1024,
                        Quality = GeneratedImageQuality.High,
                    },
                    cancellationToken
                )
                .ConfigureAwait(false);

            var generated = imageGeneration.Value;

            if (!string.IsNullOrEmpty(generated.RevisedPrompt))
            {
                _logger.LogInformation("{RevisedPrompt}", generated.RevisedPrompt);
            }

            var imageBytes = generated.ImageBytes;
            if (imageBytes != null && imageBytes.ToMemory().Length > 0)
            {
                var bytes = imageBytes.ToArray();
                return Option.From<Stream>(new MemoryStream(bytes, writable: false));
            }

            if (generated.ImageUri != null)
            {
                _logger.LogInformation("{ImageUri}", generated.ImageUri);
                try
                {
                    var http = _httpClientFactory.CreateClient();
                    var stream = await http.GetStreamAsync(generated.ImageUri, cancellationToken).ConfigureAwait(false);
                    return Option.From(stream);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to download generated image from URL.");
                    return Option.None;
                }
            }

            return Option.None;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "OpenAI image generation failed.");
            return Option.None;
        }
    }
}
