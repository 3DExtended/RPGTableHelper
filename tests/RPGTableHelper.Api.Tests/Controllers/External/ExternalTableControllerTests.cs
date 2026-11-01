using System.Net;
using System.Net.Http.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.External;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.External;

public class ExternalTableControllerTests : ExternalApiTestBase
{
    public ExternalTableControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task Me_ShowsTheKeysOwnerAndScopes_WithoutNeedingAScope()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead);

        // act
        var me = await key.GetFromJsonAsync<ExternalMeDto>($"{V1}/me", JsonOptions);

        // assert
        me!.UserId.Should().Be(hero.User.Id.Value);
        me.Username.Should().Be(hero.User.Username);
        me.ApiKey.Scopes.Should().Equal(ApiKeyScopes.NotesRead);
        me.ApiKey.Prefix.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task Me_WithAJwt_IsUnauthorized()
    {
        // act
        await ConfigureLoggedInUser();
        var response = await Client.GetAsync($"{V1}/me");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Members_ListsTheDmAndEveryPlayerWithTheirCharacters()
    {
        // arrange
        var (dm, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var rogue = await AddPlayerAsync(campagne, "Rogue");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);

        // act
        var members = await key.GetFromJsonAsync<List<ExternalCampaignMemberDto>>(
            $"{V1}/campaigns/{campagne.Id.Value}/members",
            JsonOptions
        );

        // assert
        members.Should().HaveCount(3);
        members![0].Should().BeEquivalentTo(new { UserId = dm.Id.Value, IsDm = true, IsYou = false });
        members.Single(m => m.UserId == hero.User.Id.Value).Should().BeEquivalentTo(new { IsDm = false, IsYou = true });
        members.Single(m => m.UserId == rogue.User.Id.Value).Characters.Should().ContainSingle()
            .Which.Should().BeEquivalentTo(new ExternalCharacterRefDto { Id = rogue.CharacterId, Name = "Rogue" });
    }

    [Fact]
    public async Task Members_OfACampaignYouAreNotIn_IsNotFound()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var otherCampagne = await CreateForeignCampaignAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);

        // act
        var response = await key.GetAsync($"{V1}/campaigns/{otherCampagne.Id.Value}/members");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        (await ReadErrorCodeAsync(response)).Should().Be(ExternalApiErrors.NotFound);
    }

    [Fact]
    public async Task Members_WithoutCampaignsRead_IsForbiddenWithTheMissingScope()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.NotesRead);

        // act
        var response = await key.GetAsync($"{V1}/campaigns/{campagne.Id.Value}/members");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        (await ReadErrorCodeAsync(response)).Should().Be("insufficient_scope");
    }

    [Fact]
    public async Task Config_ReturnsTheConfigurationAsAnObjectWithItsRevision()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);

        // act
        var body = JsonNode.Parse(await key.GetStringAsync($"{V1}/campaigns/{campagne.Id.Value}/config"))!;

        // assert
        body["revision"]!.GetValue<int>().Should().Be(3);
        body["config"]!["characterStatTabsDefinition"]![0]!["statsInTab"]![0]!["statUuid"]!.GetValue<string>()
            .Should().Be(HpStat);
    }

    [Fact]
    public async Task SessionEnter_WithAnOpenEventStream_PutsTheKeysOwnerAtTheTable()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.Events);
        using var stream = await KeepEventsStreamOpenAsync(key);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/enter", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK, await response.Content.ReadAsStringAsync());
        var result = await response.Content.ReadFromJsonAsync<SessionEnterResultDto>(JsonOptions);
        result!.OnlineUserIds.Should().Contain(hero.User.Id.Value.ToString());

        var leave = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/leave", null);
        leave.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task SessionEnter_WithoutTheEventsScope_IsForbidden()
    {
        // arrange
        var (_, campagne) = await CreateTableAsync();
        var hero = await AddPlayerAsync(campagne, "Hero");
        var key = await CreateApiKeyClientAsync(hero.User, ApiKeyScopes.CampaignsRead);

        // act
        var response = await key.PostAsync($"{V1}/campaigns/{campagne.Id.Value}/session/enter", null);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }
}
