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

public class CampagneControllerTests : ControllerTestBase
{
    public CampagneControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateNewCampagneAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.PostAsJsonAsync(
            "/campagne/createcampagne",
            new CampagneCreateDto { CampagneName = "TestCampagneName", RpgConfiguration = "fghjklkjhgfghjkl" }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task CreateNewCampagneAsync_ShouldBeSuccessfull()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await Client.PostAsJsonAsync(
            "/campagne/createcampagne",
            new CampagneCreateDto { CampagneName = "TestCampagneName", RpgConfiguration = "fghjklkjhgfghjkl" }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var campagnes = await context.Campagnes.Include(c => c.DmUser).ToListAsync(default);
            campagnes.Count().Should().Be(1);
            campagnes[0].CampagneName.Should().Be("TestCampagneName");
            campagnes[0].JoinCode.Should().NotBeNullOrWhiteSpace();
            campagnes[0].RpgConfiguration.Should().Be("fghjklkjhgfghjkl");
            campagnes[0].DmUserId.Should().Be(user.Id.Value);
            campagnes[0].DmUser.Should().NotBeNull();
            campagnes[0].DmUser!.Username.Should().Be(user.Username);
        }
    }

    [Fact]
    public async Task GetCampagnesForUserAsDmAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetCampagnesForUserAsDmAsync_ShouldBeSuccessfullOnEmptyLists()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await Client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<IReadOnlyList<Campagne>>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Count.Should().Be(0);
    }

    [Fact]
    public async Task GetCampagnesForUserAsDmAsync_ShouldBeSuccessfullOnNonEmptyList()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username2");

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            DmUserId = user.Id.Value,
            JoinCode = "123-123",
            RpgConfiguration = "asdf",
        };

        var entity2 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName2",
            DmUserId = user2.Id.Value,
            JoinCode = "123-124",
            RpgConfiguration = "asdasdff",
        };

        var entity3 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName3",
            DmUserId = user.Id.Value,
            JoinCode = "123-125",
            RpgConfiguration = "asdasasdfdff",
        };

        using (var context = ContextFactory.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity1);
            await context.Campagnes.AddAsync(entity2);
            await context.Campagnes.AddAsync(entity3);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<IReadOnlyList<Campagne>>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Count.Should().Be(2);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity1.Id);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity3.Id);
    }

    [Fact]
    public async Task GetCampagneByIdAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "asdfasdfasdsf");

        // act
        var response = await Client.GetAsync("/campagne/getcampagne/a25ca8ab-d8d4-4909-af94-4c08583a13ab");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetCampagneByIdAsync_ShouldBeSuccessfull()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username2");

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            DmUserId = user2.Id.Value,
            JoinCode = "123-123",
            RpgConfiguration = "asdf",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity1);
            await context.SaveChangesAsync();
        }

        var player1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = entity1.Id,
            CharacterName = "Kardan",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "vbnjklökjhg",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(player1);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/campagne/getcampagne/" + entity1.Id);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<Campagne>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Id.Value.Should().Be(entity1.Id);
    }

    [Fact]
    public async Task GetCampagneByIdAsync_ShouldReturnUnauthorizedForCampagneWhereUserIsNotPlayer()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username2");
        var user3 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Username3");

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            DmUserId = user2.Id.Value,
            JoinCode = "123-123",
            RpgConfiguration = "asdf",
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity1);
            await context.SaveChangesAsync();
        }

        var player1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = entity1.Id,
            CharacterName = "Kardan",
            PlayerUserId = user3.Id.Value,
            RpgCharacterConfiguration = "vbnjklökjhg",
        };
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(player1);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync("/campagne/getcampagne/" + entity1.Id);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}
