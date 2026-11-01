using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using Prodot.Patterns.Cqrs;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.ApiKeys;

namespace RPGTableHelper.Api.Tests.Controllers.Authorization;

/// <summary>
/// An API key only reaches the external player API and the event stream, and only with the scopes the
/// player granted it. Everything else, including key management, needs a normal login.
/// </summary>
public class ApiKeyScopesTests : ControllerTestBase
{
    public ApiKeyScopesTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateKey_WithScopes_ReturnsTheGrantedScopes()
    {
        // arrange
        await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/api/apikeys",
            new CreateApiKeyRequestDto
            {
                Name = "Companion",
                Scopes = new List<string> { ApiKeyScopes.NotesWrite, ApiKeyScopes.NotesRead },
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadFromJsonAsync<CreateApiKeyResponse>();
        body!.PlainKey.Should().StartWith("sk-");
        body.ApiKey.Scopes.Should().Equal(ApiKeyScopes.NotesRead, ApiKeyScopes.NotesWrite);
    }

    [Fact]
    public async Task CreateKey_WithUnknownScope_ReturnsBadRequest()
    {
        // arrange
        await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/api/apikeys",
            new CreateApiKeyRequestDto { Name = "Bad", Scopes = new List<string> { "admin:everything" } }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await response.Content.ReadAsStringAsync()).Should().Contain("admin:everything");
    }

    [Fact]
    public async Task CreateKey_WithEmptyScopeList_ReturnsBadRequest()
    {
        // arrange
        await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/api/apikeys",
            new CreateApiKeyRequestDto { Name = "Empty", Scopes = new List<string>() }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task CreateKey_WithoutScopesField_GetsTheLegacyReadScopes()
    {
        // arrange: older app versions do not know about scopes.
        await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync("/api/apikeys", new { name = "Old app" });

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadFromJsonAsync<CreateApiKeyResponse>();
        body!.ApiKey.Scopes.Should().BeEquivalentTo(ApiKeyScopes.LegacyDefault);
    }

    [Fact]
    public async Task CreateKey_WithExpiryInThePast_ReturnsBadRequest()
    {
        // arrange
        await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/api/apikeys",
            new CreateApiKeyRequestDto
            {
                Name = "Expired",
                Scopes = new List<string> { ApiKeyScopes.NotesRead },
                ExpiresAt = SystemClock.Now.AddMinutes(-5),
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task ApiKey_CannotListOrCreateApiKeys()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.All.ToArray());

        // act
        var listResponse = await keyClient.GetAsync("/api/apikeys");
        var createResponse = await keyClient.PostAsJsonAsync(
            "/api/apikeys",
            new CreateApiKeyRequestDto { Name = "Escalation", Scopes = ApiKeyScopes.All.ToList() }
        );

        // assert
        listResponse.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        createResponse.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ApiKey_CannotReachInternalAppEndpoints()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.All.ToArray());

        // act
        var charactersResponse = await keyClient.GetAsync("/PlayerCharacter/getplayercharacters");
        var askForRollsResponse = await keyClient.PostAsJsonAsync(
            $"/SessionCommand/askplayersforrolls/{campagne.Id.Value}",
            new { fightUuid = Guid.NewGuid().ToString(), sequence = Array.Empty<object>() }
        );

        // assert
        charactersResponse.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        askForRollsResponse.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ExternalEndpoint_WithMatchingScope_ReturnsOk()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.CharactersRead);

        // act
        var response = await keyClient.GetAsync("/api/external/v1/characters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task ExternalEndpoint_WithoutMatchingScope_ReturnsForbiddenNamingTheMissingScope()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.NotesRead);

        // act
        var response = await keyClient.GetAsync("/api/external/v1/characters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        body.RootElement.GetProperty("error").GetString().Should().Be("insufficient_scope");
        body.RootElement.GetProperty("requiredScopes")
            .EnumerateArray()
            .Select(e => e.GetString())
            .Should()
            .Equal(ApiKeyScopes.CharactersRead);
    }

    [Fact]
    public async Task LegacyExternalRoute_StillWorks_ForOldKeys()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.LegacyDefault.ToArray());

        // act
        var response = await keyClient.GetAsync("/api/external/campaigns");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task ExternalEndpoint_RejectsJwtWithoutApiKey()
    {
        // arrange
        await ConfigureLoggedInUser();

        // act
        var response = await Client.GetAsync("/api/external/v1/characters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task RevokedKey_IsRejected()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        var plainKey = await CreateApiKeyAsync(user, ApiKeyScopes.CharactersRead);
        var keys = await new GetUserApiKeysQuery { UserId = user.Id }.RunAsync(QueryProcessor, CancellationToken.None);
        await new RevokeApiKeyQuery { UserId = user.Id, ApiKeyId = keys.Get().Single().Id }.RunAsync(
            QueryProcessor,
            CancellationToken.None
        );

        using var keyClient = Factory.CreateClient();
        keyClient.DefaultRequestHeaders.Add("X-Api-Key", plainKey);

        // act
        var response = await keyClient.GetAsync("/api/external/v1/characters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Events_WithKeyWithoutEventsScope_ReturnsForbidden()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.NotesRead);

        // act
        using var response = await keyClient.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Events_WithEventsScope_StreamsHello()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var keyClient = await CreateApiKeyClientAsync(user, ApiKeyScopes.Events);

        // act
        using var response = await keyClient.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        await using var stream = await response.Content.ReadAsStreamAsync();
        using var reader = new StreamReader(stream, Encoding.UTF8);
        (await reader.ReadLineAsync()).Should().Be("event: hello");
        (await reader.ReadLineAsync()).Should().Contain(user.Id.Value.ToString());
    }

    [Fact]
    public async Task Events_WithJwt_StillWorks()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
        using var jwtClient = Factory.CreateClient();
        jwtClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", CreateJwtForUser(user));

        // act
        using var response = await jwtClient.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
