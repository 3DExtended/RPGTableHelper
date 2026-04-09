using FluentAssertions;
using Microsoft.Extensions.Logging;
using NSubstitute;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Options;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;
using RPGTableHelper.DataLayer.OpenAI.QueryHandlers;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.OpenAI;

public class AiGenerateImageQueryHandlerTests
{
    [Fact]
    public async Task RunQueryAsync_WhenApiKeyMissing_ReturnsNone()
    {
        var options = new OpenAIOptions { ApiKey = null };
        var httpFactory = Substitute.For<IHttpClientFactory>();
        var logger = Substitute.For<ILogger<AiGenerateImageQueryHandler>>();
        var subjectUnderTest = new AiGenerateImageQueryHandler(options, httpFactory, logger);
        var query = new AiGenerateImageQuery { ImagePrompt = "a red cube" };

        var result = await subjectUnderTest.RunQueryAsync(query, default);

        result.IsSome.Should().BeFalse();
    }
}
