using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>The published player API document: v1 only, every operation with the API key and its scope.</summary>
public class ExternalApiSwaggerTests : ExternalApiTestBase
{
    public ExternalApiSwaggerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task TheDocument_ListsOnlyV1_AndEveryOperationNeedsTheApiKey()
    {
        // act
        var document = JsonNode.Parse(await Client.GetStringAsync("/swagger/external/swagger.json"))!;

        // assert
        var paths = document["paths"]!.AsObject();
        paths.Select(p => p.Key).Should().OnlyContain(path => path.StartsWith("/api/external/v1/"));
        paths.Select(p => p.Key).Should().Contain(
            new[]
            {
                "/api/external/v1/me",
                "/api/external/v1/characters/{characterId}/sheet",
                "/api/external/v1/documents/{documentId}/blocks",
                "/api/external/v1/campaigns/{campaignId}/fight/rolls",
            }
        );

        foreach (var (path, operations) in paths)
        {
            foreach (var (method, operation) in operations!.AsObject())
            {
                var because = $"{method.ToUpperInvariant()} {path} is part of the player API";
                operation!["security"]!.ToJsonString().Should().Contain("ApiKey", because);
                operation["description"]!.GetValue<string>().Should().MatchRegex("scope", because);
                operation["responses"]!.AsObject().Select(r => r.Key).Should().Contain(new[] { "401", "429" }, because);
            }
        }
    }

    [Fact]
    public async Task WritingASheet_NamesItsScope()
    {
        // act
        var document = JsonNode.Parse(await Client.GetStringAsync("/swagger/external/swagger.json"))!;

        // assert
        document["paths"]!["/api/external/v1/characters/{characterId}/sheet"]!["patch"]!["description"]!
            .GetValue<string>().Should().Contain("characters:write");
    }
}
