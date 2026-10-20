using System.Diagnostics;
using System.Net;

using FluentAssertions;

using Microsoft.AspNetCore.Authorization;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;

using NSubstitute;

using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Health;

/// <summary>
/// GET /health is what the cockpit's uptime check asks every minute: 2xx is up; a redirect, any other status,
/// no answer within 10 s or a body over 64 KB is down. The path is that contract, so the tests spell it out.
/// </summary>
public class HealthEndpointTests
{
    private const int SqliteBusy = 5;

    [Fact]
    public async Task Get_WhenTheDatabaseIsReachable_Answers200WithHealthyAsPlainText()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        // act
        using var response = await client.GetAsync("/health");

        // assert
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
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Head, "/health");

        // act
        using var response = await client.SendAsync(request);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Post_IsNotAllowed()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        // act
        using var response = await client.PostAsync("/health", content: null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.MethodNotAllowed);
    }

    [Fact]
    public async Task Get_WithoutCredentials_StaysAnonymousEvenUnderAFallbackPolicy()
    {
        // arrange
        await using var host = HealthTestHost.Start(services =>
            services.PostConfigure<AuthorizationOptions>(options =>
                options.FallbackPolicy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build()
            )
        );
        using var client = host.CreateClient();

        // An endpoint without an attribute of its own now needs a login, so the fallback policy is in force ...
        using var guarded = await client.GetAsync("/public/getminimalversion");
        guarded.StatusCode.Should().Be(HttpStatusCode.Unauthorized);

        // act
        using var response = await client.GetAsync("/health");

        // assert
        // ... and /health still answers without one, because it is marked anonymous itself.
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        (await response.Content.ReadAsStringAsync()).Should().Be("Healthy");
    }

    [Fact]
    public async Task GetAndHead_OnKestrelOverPlainHttpFromTheTunnel_AreNotRedirected()
    {
        // arrange
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

            // act
            using var response = await client.SendAsync(request);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.OK, $"{method} /health must not be redirected");
            response.Headers.Location.Should().BeNull();
            (await response.Content.ReadAsStringAsync()).Should().Be(method == HttpMethod.Get ? "Healthy" : string.Empty);
        }
    }

    [Fact]
    public async Task Get_WhenTheDatabaseFileIsGone_Answers503UnhealthyAndDoesNotRecreateIt()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.DeleteDatabaseFile();

        // act
        using var response = await client.GetAsync("/health");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        File.Exists(host.DatabasePath).Should().BeFalse("the check must never create an empty database");
    }

    [Fact]
    public async Task Get_WhenTheDatabaseFileIsEmpty_Answers503AndLeavesItEmpty()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.EmptyDatabaseFile();

        // act
        using var response = await client.GetAsync("/health");

        // assert
        // SQLite opens an empty file as an empty database; without the app's tables nothing else would work.
        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        new FileInfo(host.DatabasePath).Length.Should().Be(0, "the check must never write a schema or a header");
    }

    [Fact]
    public async Task Get_WhenTheDatabaseFileIsNotADatabase_Answers503AndLogsTheReasonOnceOnTheServer()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.OverwriteDatabaseFileWithGarbage();

        // act
        using var response = await client.GetAsync("/health");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        response.Content.Headers.ContentType!.MediaType.Should().Be("text/plain");

        // The reason goes to the server log, not into the answer, and once: the check is asked every minute.
        host.Logs.Entries.Where(entry => entry.Level >= LogLevel.Error)
            .Should()
            .ContainSingle()
            .Which.Category.Should()
            .StartWith("Microsoft.Extensions.Diagnostics.HealthChecks");
    }

    [Fact]
    public async Task Get_WhenTheDatabaseIsLocked_GivesUpWithSqlitesOwnAnswerAndLogsItOnce()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        using var databaseLock = host.LockDatabase();

        // act
        var stopwatch = Stopwatch.StartNew();
        using var response = await client.GetAsync("/health");
        stopwatch.Stop();

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        stopwatch.Elapsed.Should().BeLessThan(TimeSpan.FromSeconds(6));

        // The probe ran into its own command timeout, so it is over and logged the lock itself, nothing left behind.
        host.Logs.Entries.Where(entry => entry.Level >= LogLevel.Error)
            .Should()
            .ContainSingle()
            .Which.Exception.Should()
            .BeOfType<SqliteException>()
            .Which.SqliteErrorCode.Should()
            .Be(SqliteBusy);
    }

    [Fact]
    public async Task Get_WhenTheDatabaseHangs_Answers503WellWithinTheUptimeChecksTenSeconds()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();
        host.Commands.Hang();

        // act
        var stopwatch = Stopwatch.StartNew();
        using var response = await client.GetAsync("/health");
        stopwatch.Stop();

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.ServiceUnavailable);
        (await response.Content.ReadAsStringAsync()).Should().Be("Unhealthy");
        stopwatch.Elapsed.Should().BeLessThan(TimeSpan.FromSeconds(6));
        host.Commands.Executed.Should().NotBeEmpty("the probe was stuck in the database, not skipped");
    }

    [Fact]
    public async Task Get_OnlyReadsFromTheDatabase()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        // act
        for (var i = 0; i < 3; i++)
        {
            using var response = await client.GetAsync("/health");
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        // assert
        host.Commands.Executed.Should()
            .NotBeEmpty()
            .And.OnlyContain(sql => sql.TrimStart().StartsWith("SELECT", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task Get_CountsNoOneAsConnectedOrPresent()
    {
        // arrange
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

        // act
        using var response = await client.GetAsync("/health");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        sseEventHub.ReceivedCalls().Should().BeEmpty();
        sessionPresence.ReceivedCalls().Should().BeEmpty();
    }

    [Fact]
    public async Task Get_LogsNothingAtInformationOrAbovePerRequest()
    {
        // arrange
        await using var host = HealthTestHost.Start();
        using var client = host.CreateClient();

        // The first request of a process may log what is looked up once (like the https port); later ones may not.
        using (var first = await client.GetAsync("/health"))
        {
            first.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        host.Logs.Clear();

        // act
        // More than 20, so EF would warn here if every check built its own internal service provider.
        for (var i = 0; i < 25; i++)
        {
            using var response = await client.GetAsync("/health");
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        // assert
        host.Logs.Entries.Where(entry => entry.Level >= LogLevel.Information).Should().BeEmpty();
    }
}
