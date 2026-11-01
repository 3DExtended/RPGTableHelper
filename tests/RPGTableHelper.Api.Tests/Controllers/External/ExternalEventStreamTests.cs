using System.Net;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.Fights;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// An event stream opened with an API key gets only the events its scopes cover; the app's stream of the same
/// player still gets everything.
/// </summary>
public class ExternalEventStreamTests : ExternalApiTestBase
{
    public ExternalEventStreamTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task AKeyWithFightsPlay_GetsTheInitiativeRequestButNotTheAppsLegacyEvents()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.Events, ApiKeyScopes.FightsPlay);
        using var keyEvents = await KeepEventsStreamOpenAsync(key);
        using var appEvents = await KeepEventsStreamOpenAsync(hero.AppClient);
        using var dmEvents = await KeepEventsStreamOpenAsync(Client);
        await EnterAsync(Client, campagne);
        await EnterAsync(key, campagne, external: true);

        // act
        var fightId = await StartFightAsync(campagne, hero.Uuid);
        (await Client.PostAsync($"/Fight/{fightId}/end", null)).EnsureSuccessStatusCode();

        // assert
        var keyTypes = await ReadEventTypesUntilAsync(keyEvents, "fightEnded");
        keyTypes.Should().Equal("initiativeRequested", "fightEnded");

        var appTypes = await ReadEventTypesUntilAsync(appEvents, "fightEnded");
        appTypes.Should().Contain(new[] { "initiativeRequested", "playersAreAskedForRolls" });
    }

    [Fact]
    public async Task AKeyWithoutFightsPlay_GetsNoFightEvents()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.Events);
        using var keyEvents = await KeepEventsStreamOpenAsync(key);
        using var dmEvents = await KeepEventsStreamOpenAsync(Client);
        using var rogueEvents = await KeepEventsStreamOpenAsync(rogue.AppClient);
        await EnterAsync(Client, campagne);
        await EnterAsync(key, campagne, external: true);
        await StartFightAsync(campagne, hero.Uuid);

        // act: the rogue sitting down is the next thing the key may hear about
        await EnterAsync(rogue.AppClient, campagne);

        // assert
        var keyTypes = await ReadEventTypesUntilAsync(keyEvents, "participantOnline");
        keyTypes.Should().Equal("participantOnline");
    }

    [Fact]
    public async Task AKeyWithNotesRead_HearsAboutABlockSharedWithItsOwner()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.Events, ApiKeyScopes.NotesRead);
        using var keyEvents = await KeepEventsStreamOpenAsync(key);
        var dmKey = await CreateApiKeyClientAsync(dm, ApiKeyScopes.NotesWrite);

        // act
        var document = await dmKey.PostAsync(
            $"{V1}/campaigns/{campagne.Id.Value}/documents",
            Json(new { title = "Handout", groupName = "Lore" })
        );
        var documentId = System.Text.Json.Nodes.JsonNode.Parse(await document.Content.ReadAsStringAsync())!["id"]!;
        var block = await dmKey.PostAsync(
            $"{V1}/documents/{documentId}/blocks",
            Json(new { markdownText = "The map", visibleTo = new[] { hero.User.Id.Value } })
        );

        // assert
        block.StatusCode.Should().Be(HttpStatusCode.Created);
        var data = await ReadUntilEventAsync(keyEvents, "noteAccessChanged");
        data.Should().Contain(documentId.ToString());
    }

    /// <summary>Event types in arrival order, up to and including <paramref name="lastEventType"/>.</summary>
    private static async Task<List<string>> ReadEventTypesUntilAsync(StreamReader reader, string lastEventType)
    {
        var types = new List<string>();
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(5));
        while (types.LastOrDefault() != lastEventType)
        {
            var line = await reader.ReadLineAsync(timeout.Token);
            line.Should().NotBeNull("the event stream should stay open");
            if (line!.StartsWith("event: ", StringComparison.Ordinal))
            {
                types.Add(line["event: ".Length..]);
            }
        }

        return types;
    }

    private static async Task EnterAsync(HttpClient client, Campagne campagne, bool external = false)
    {
        var path = external ? $"{V1}/campaigns/{campagne.Id.Value}/session/enter" : $"/Session/enter/{campagne.Id.Value}";
        (await client.PostAsync(path, null)).EnsureSuccessStatusCode();
    }

    private async Task<Guid> StartFightAsync(Campagne campagne, params string[] characterUuids)
    {
        var response = await Client.PostAsync(
            $"/Fight/start/{campagne.Id.Value}",
            Json(new StartFightRequestDto
            {
                Participants = characterUuids.Select(uuid => new StartFightParticipantDto { CharacterUuid = uuid }).ToList(),
            })
        );
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var fight = System.Text.Json.Nodes.JsonNode.Parse(await response.Content.ReadAsStringAsync())!;
        return fight["id"]!.GetValue<Guid>();
    }
}
