using System.Diagnostics;
using System.Net;

using FluentAssertions;

using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;

using NSubstitute;

using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Health;

/// <summary>
/// GET /health is what the cockpit's uptime check asks every minute: 2xx is up; a redirect, any other status,
/// no answer within 10 s or a body over 64 KB is down.
/// </summary>
public class HealthEndpointTests
{
    [Fact]
    public async Task Get_WhenTheDatabaseIsReachable_Answers200WithHealthyAsPlainText()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        using var response = await client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        (await response.Content.ReadAsStringAsync()).Should().Be("Healthy");
        response.Content.Headers.ContentType!.MediaType.Should().Be("text/plain");
        response.Headers.CacheControl!.NoStore.Should().BeTrue();
        response.Headers.Location.Should().BeNull();
        response.Headers.Contains("Set-Cookie").Should().BeFalse();
    }

    [Fact]
    public async Task Head_WhenTheDatabaseIsReachable_Answers200()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Head, "/health");

        using var response = await client.SendAsync(request);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Post_IsNotAllowed()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        using var response = await client.PostAsync("/health", content: null);

        response.StatusCode.Should().Be(HttpStatusCode.MethodNotAllowed);
    }

    [Fact]
    public async Task Get_WithoutCredentials_StaysAnonymousEvenUnderAFallbackPolicy()
    {
        await using var host = HealthTestHost.Start(services =>
            services.PostConfigure<AuthorizationOptions>(options =>
                options.FallbackPolicy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build()
            )
        );
        using var client = host.CreateClient();

        // An endpoint without an attribute of its own now needs a login, so the fallback policy is in force ...
        using var guarded = await client.GetAsync("/public/getminimalversion");
        guarded.StatusCode.Should().Be(HttpStatusCode.Unauthorized);

        // ... and /health still answers without one, because it is marked anonymous itself.
        using var response = await client.GetAsync("/health");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        (await response.Content.ReadAsStringAsync()).Should().Be("Healthy");
    }

    [Fact]
    public async Task GetAndHead_OnKestrelOverPlainHttpFromTheTunnel_AreNotRedirected()
    {
        await using var host = HealthTestHost.StartOnKestrel();
        using var client = host.CreateClient();
        client.BaseAddress!.Scheme.Should().Be("http");

        foreach (var method in new[] { HttpMethod.Get, HttpMethod.Head })
        {
            using var request = new HttpRequestMessage(method, "/health");

            // What cloudflared adds when it hands the cockpit's https request to the container over plain http.
            request.Headers.Host = HealthTestHost.PublicHost;
            request.Headers.Add("X-Forwarded-Proto", "https");
            request.Headers.Add("Cf-Visitor", "{\"scheme\":\"https\"}");

            using var response = await client.SendAsync(request);

            response.StatusCode.Should().Be(HttpStatusCode.OK, $"{method} /health must not be redirected");
            response.Headers.Location.Should().BeNull();
            (await response.Content.ReadAsStringAsync()).Should().Be(method == HttpMethod.Get ? "Healthy" : string.Empty);
        }
    }

    [Fact]
    public async Task Get_WhenTheDatabaseFileIsGone_Answers503UnhealthyAndDoesNotRecreateIt()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.DeleteDatabaseFile();

        using var response = await client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        File.Exists(host.DatabasePath).Should().BeFalse("the check must never create an empty database");
    }

    [Fact]
    public async Task Get_WhenTheDatabaseFileIsNotADatabase_Answers503WithNothingButUnhealthy()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.OverwriteDatabaseFileWithGarbage();

        using var response = await client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        response.Content.Headers.ContentType!.MediaType.Should().Be("text/plain");

        // The reason goes to the server log, not into the answer.
        host.Logs.Entries.Should()
            .Contain(entry =>
                entry.Level >= LogLevel.Error
                && entry.Category.StartsWith("Microsoft.Extensions.Diagnostics.HealthChecks", StringComparison.Ordinal)
            );
    }

    [Fact]
    public async Task Get_WhenTheDatabaseHangs_Answers503WellWithinTheUptimeChecksTenSeconds()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.Commands.Hang();

        var stopwatch = Stopwatch.StartNew();
        using var response = await client.GetAsync("/health");
        stopwatch.Stop();

        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        stopwatch.Elapsed.Should().BeLessThan(TimeSpan.FromSeconds(6));
        host.Commands.Executed.Should().NotBeEmpty("the probe was stuck in the database, not skipped");
    }

    [Fact]
    public async Task Get_OnlyReadsFromTheDatabase()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        for (var i = 0; i < 3; i++)
        {
            using var response = await client.GetAsync("/health");
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        host.Commands.Executed.Should()
            .NotBeEmpty()
            .And.OnlyContain(sql => sql.TrimStart().StartsWith("SELECT", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task Get_CountsNoOneAsConnectedOrPresent()
    {
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sessionPresence = Substitute.For<ISessionPresenceService>();
        await using var host = HealthTestHost.Start(services =>
        {
            services.RemoveAll<ISseEventHub>();
            services.AddSingleton(sseEventHub);
            services.RemoveAll<ISessionPresenceService>();
            services.AddSingleton(sessionPresence);
        });
        using var client = host.CreateClient();

        using var response = await client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        sseEventHub.ReceivedCalls().Should().BeEmpty();
        sessionPresence.ReceivedCalls().Should().BeEmpty();
    }

    [Fact]
    public async Task Get_LogsNothingAtInformationOrAbovePerRequest()
    {
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        // The first request of a process may log what is looked up once (like the https port); later ones may not.
        using (var first = await client.GetAsync("/health"))
        {
            first.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        host.Logs.Clear();

        for (var i = 0; i < 3; i++)
        {
            using var response = await client.GetAsync("/health");
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        host.Logs.Entries.Where(entry => entry.Level >= LogLevel.Information).Should().BeEmpty();
    }
}
