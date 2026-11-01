using System.Net;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>Each API key may make 120 requests a minute, 30 of them writes; other keys are not affected.</summary>
public class ExternalApiRateLimitTests : ExternalApiTestBase
{
    public ExternalApiRateLimitTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task TheRequestAfterTheMinutesLimit_IsRejectedWithRetryAfter_ForThatKeyOnly()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);
        var otherKey = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);
        for (var i = 0; i < 120; i++)
        {
            (await key.GetAsync($"{V1}/me")).StatusCode.Should().Be(HttpStatusCode.OK, $"request {i + 1} is within the limit");
        }

        // act
        var limited = await key.GetAsync($"{V1}/me");
        var other = await otherKey.GetAsync($"{V1}/me");

        // assert
        limited.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);
        limited.Headers.RetryAfter.Should().NotBeNull();
        var body = JsonNode.Parse(await limited.Content.ReadAsStringAsync())!;
        body["error"]!.GetValue<string>().Should().Be("rate_limited");
        body["retryAfterSeconds"]!.GetValue<int>().Should().BePositive();
        other.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task TheWriteAfterThirtyWrites_IsRejected_WhileReadsStillWork()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.Events);
        for (var i = 0; i < 30; i++)
        {
            (await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/leave", null))
                .StatusCode.Should().Be(HttpStatusCode.NoContent, $"write {i + 1} is within the limit");
        }

        // act
        var limited = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/leave", null);
        var read = await key.GetAsync($"{V1}/me");

        // assert
        limited.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);
        read.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task TheApp_IsNotLimited()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();

        // act
        var statuses = new List<HttpStatusCode>();
        for (var i = 0; i < 130; i++)
        {
            statuses.Add((await Client.GetAsync($"/Fight/current/{campagne.Id.Value}")).StatusCode);
        }

        // assert
        statuses.Should().OnlyContain(s => s == HttpStatusCode.OK);
    }
}
