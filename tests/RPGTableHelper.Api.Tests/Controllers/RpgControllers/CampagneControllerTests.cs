using System.Net;
using System.Net.Http.Headers;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Options;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class CampagneControllerTests : ControllerTestBase
{
    public CampagneControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateNewCampagneAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            "asdfasdfasdsf"
        );

        // act
        var response = await _client.PostAsJsonAsync(
            "/campagne/createcampagne",
            new CampagneCreateDto
            {
                CampagneName = "TestCampagneName",
                RpgConfiguration = "fghjklkjhgfghjkl",
            }
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
        var response = await _client.PostAsJsonAsync(
            "/campagne/createcampagne",
            new CampagneCreateDto
            {
                CampagneName = "TestCampagneName",
                RpgConfiguration = "fghjklkjhgfghjkl",
            }
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
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            "asdfasdfasdsf"
        );

        // act
        var response = await _client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetCampagnesForUserAsDmAsync_ShouldBeSuccessfullOnEmptyLists()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await _client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadAsAsync<IReadOnlyList<Campagne>>();
        responseParsed.Should().NotBeNull();
        responseParsed.Count.Should().Be(0);
    }

    [Fact]
    public async Task GetCampagnesForUserAsDmAsync_ShouldBeSuccessfullOnNonEmptyList()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory!,
            Mapper!,
            usernameOverride: "Username2"
        );

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
        var response = await _client.GetAsync("/campagne/getcampagnes");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadAsAsync<IReadOnlyList<Campagne>>();
        responseParsed.Should().NotBeNull();
        responseParsed.Count.Should().Be(2);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity1.Id);
        responseParsed.Select(x => x.Id.Value).Should().Contain(entity3.Id);
    }

    protected async Task<User> ConfigureLoggedInUser()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);

        var jwtOptions = new JwtOptions
        {
            Issuer = "api",
            Audience = "api",
            Key = string.Join("", Enumerable.Repeat("asdfasdf", 200)),
            NumberOfSecondsToExpire = 12000,
        };

        var tokenGenerator = new JWTTokenGenerator(SystemClock, jwtOptions);

        var jwt = tokenGenerator.GetJWTToken(user.Username, user.Id.Value.ToString());
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwt!);

        // act
        var response = await _client.GetAsync("/SignIn/testlogin");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        return user!;
    }
}
