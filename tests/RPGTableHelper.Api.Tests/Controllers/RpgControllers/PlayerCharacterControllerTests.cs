using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class PlayerCharacterControllerTests : ControllerTestBase
{
    public PlayerCharacterControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateNewPlayerCharacterAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.PostAsJsonAsync(
            "/PlayerCharacter/createcharacter",
            new PlayerCharacterCreateDto
            {
                CharacterName = "TestCharacterName",
                RpgCharacterConfiguration = "fghjklkjhgfghjkl",
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task CreateNewPlayerCharacterAsync_ShouldBeSuccessfull()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/PlayerCharacter/createcharacter",
            new PlayerCharacterCreateDto
            {
                CharacterName = "TestCharacterName",
                RpgCharacterConfiguration = "fghjklkjhgfghjkl",
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var playerCharacters = await context.PlayerCharacters.Include(c => c.PlayerUser).ToListAsync(default);
            playerCharacters.Count().Should().Be(1);
            playerCharacters[0].CharacterName.Should().Be("TestCharacterName");
            playerCharacters[0].RpgCharacterConfiguration.Should().Be("fghjklkjhgfghjkl");
            playerCharacters[0].PlayerUserId.Should().Be(user.Id.Value);
            playerCharacters[0].PlayerUser.Should().NotBeNull();
            playerCharacters[0].PlayerUser!.Username.Should().Be(user.Username);
        }
    }

    [Fact]
    public async Task GetPlayerCharactersForUserAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.GetAsync("/PlayerCharacter/getplayercharacters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetPlayerCharactersForUserAsync_ShouldBeSuccessfullOnEmptyLists()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await Client.GetAsync("/PlayerCharacter/getplayercharacters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<IReadOnlyList<Campagne>>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Count.Should().Be(0);
    }

    [Fact]
    public async Task GetPlayerCharactersForUserAsync_ShouldBeSuccessfullOnNonEmptyList()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username2");

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };

        var entity2 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName2",
            PlayerUserId = user2.Id.Value,
            RpgCharacterConfiguration = "asdasdff",
        };

        var entity3 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName3",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "asdasasdfdff",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity1);
            await context.PlayerCharacters.AddAsync(entity2);
            await context.PlayerCharacters.AddAsync(entity3);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/PlayerCharacter/getplayercharacters");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<IReadOnlyList<PlayerCharacter>>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Count.Should().Be(2);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity1.Id);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity3.Id);
    }

    [Fact]
    public async Task GetPlayerCharacterByIdAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.GetAsync(
            "/PlayerCharacter/getplayercharacter/a25ca8ab-d8d4-4909-af94-4c08583a13ab"
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetPlayerCharacterByIdAsync_ShouldBeSuccessfull()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity1);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/PlayerCharacter/getplayercharacter/" + entity1.Id);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<Campagne>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Id.Value.Should().Be(entity1.Id);
    }

    [Fact]
    public async Task GetPlayerCharacterByIdAsync_ShouldReturnUnauthorizedForPlayerYouDontOwn()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username2");

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user2.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity1);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/PlayerCharacter/getplayercharacter/" + entity1.Id);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}
