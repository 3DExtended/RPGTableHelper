using System.ClientModel;
using Azure;
using Azure.AI.OpenAI;
using OpenAI;
using OpenAI.Images;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Options;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;

namespace RPGTableHelper.DataLayer.OpenAI.QueryHandlers;

public class AiGenerateImageQueryHandler : IQueryHandler<AiGenerateImageQuery, string>
{
    private readonly OpenAIOptions _options;

    public AiGenerateImageQueryHandler(OpenAIOptions options)
    {
        _options = options;
    }

    public IQueryHandler<AiGenerateImageQuery, string> Successor { get; set; } = default!;

    public async Task<Option<string>> RunQueryAsync(AiGenerateImageQuery query, CancellationToken cancellationToken)
    {
        if (_options.ApiKey == null || _options.OpenAIUrl == null)
        {
            return Option.None;
        }

        var endpoint = _options.OpenAIUrl;
        var key = _options.ApiKey;

        var azureClient = new AzureOpenAIClient(new Uri(endpoint), new ApiKeyCredential(key));

        // This must match the custom deployment name you chose for your model
        ImageClient chatClient = azureClient.GetImageClient("dall-e-3");

        try
        {
            var imageGeneration = await chatClient.GenerateImageAsync(
                query.ImagePrompt,
                new ImageGenerationOptions()
                {
                    Size = GeneratedImageSize.W1024xH1024,
                    Style = GeneratedImageStyle.Vivid,
                    Quality = GeneratedImageQuality.Standard,
                    ResponseFormat = GeneratedImageFormat.Uri,
                }
            );

            Console.WriteLine(imageGeneration.Value.ImageUri);
            Console.WriteLine(imageGeneration.Value.RevisedPrompt);
            return imageGeneration.Value.ImageUri.ToString();
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }

        return Option.None;
    }
}
