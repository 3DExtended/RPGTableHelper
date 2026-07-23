using System.Net;
using System.Net.Http.Json;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class CampagneConfigRevisionControllerTests : ControllerTestBase
{
    public CampagneConfigRevisionControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task PatchCampagneRpgConfigAsync_ShouldApplyPatchWhenRevisionMatches()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN01",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"new\"}]",
        };

        // act
        var response = await Client.PatchAsJsonAsync($"/Campagne/patchcampagneconfig/{entity.Id}", patchRequest);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigWriteResultDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Revision.Should().Be(2);

        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.Campagnes.SingleAsync(c => c.Id == entity.Id);
            stored.RpgConfiguration.Should().Be("{\"rpgName\":\"new\"}");
            stored.RpgConfigurationMergedRevision.Should().Be(2);
        }
    }

    [Fact]
    public async Task PatchCampagneRpgConfigAsync_ShouldReturnConflictWhenFromRevisionIsStale()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN02",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 5,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"hacked\"}]",
        };

        // act
        var response = await Client.PatchAsJsonAsync($"/Campagne/patchcampagneconfig/{entity.Id}", patchRequest);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.Campagnes.SingleAsync(c => c.Id == entity.Id);
            stored.RpgConfiguration.Should().Be("{\"rpgName\":\"old\"}");
            stored.RpgConfigurationMergedRevision.Should().Be(5);
        }
    }

    [Fact]
    public async Task UpdateCampagneRpgConfigAsync_ShouldReturnConflictWhenFromRevisionProvidedAndStale()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN03",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 5,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.PutAsJsonAsync(
            $"/Campagne/updatecampagneconfig/{entity.Id}",
            new CampagneUpdateRpgConfigDto { RpgConfiguration = "{\"rpgName\":\"hacked\"}", FromRevision = 1 }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.Campagnes.SingleAsync(c => c.Id == entity.Id);
            stored.RpgConfiguration.Should().Be("{\"rpgName\":\"old\"}");
            stored.RpgConfigurationMergedRevision.Should().Be(5);
        }
    }

    [Fact]
    public async Task GetCampagneRpgConfigAsync_ShouldReturnFullWhenNoSinceRevisionProvided()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN04",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 3,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync($"/Campagne/getcampagneconfig/{entity.Id}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Kind.Should().Be("full");
        responseParsed.Revision.Should().Be(3);
        responseParsed.FullConfig.Should().Be("{\"rpgName\":\"old\"}");
    }

    [Fact]
    public async Task GetCampagneRpgConfigAsync_ShouldReturnPatchWhenSinceRevisionHasHistorySnapshot()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN05",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"old\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var patchResponse = await Client.PatchAsJsonAsync(
            $"/Campagne/patchcampagneconfig/{entity.Id}",
            new ConfigPatchRequestDto
            {
                FromRevision = 1,
                Patch = "[{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"new\"}]",
            }
        );
        patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // act
        var response = await Client.GetAsync($"/Campagne/getcampagneconfig/{entity.Id}?sinceRevision=2");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Kind.Should().Be("patch");
        responseParsed.Revision.Should().Be(2);
        responseParsed.FromRevision.Should().Be(2);
        responseParsed.Patch.Should().Be("[]");
    }

    [Fact]
    public async Task GetCampagneRpgConfigAsync_ShouldReturnFullWhenSinceRevisionIsOlderThanHistoryWindow()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "CampagneName1",
            JoinCode = "JOIN06",
            DmUserId = user.Id.Value,
            RpgConfiguration = "{\"rpgName\":\"v0\"}",
            RpgConfigurationMergedRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.Campagnes.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        for (var i = 0; i < 11; i++)
        {
            var patchResponse = await Client.PatchAsJsonAsync(
                $"/Campagne/patchcampagneconfig/{entity.Id}",
                new ConfigPatchRequestDto
                {
                    FromRevision = i + 1,
                    Patch = $"[{{\"op\":\"replace\",\"path\":\"/rpgName\",\"value\":\"v{i + 1}\"}}]",
                }
            );
            patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        // act
        var response = await Client.GetAsync($"/Campagne/getcampagneconfig/{entity.Id}?sinceRevision=2");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Kind.Should().Be("full");
        responseParsed.Revision.Should().Be(12);
        responseParsed.FullConfig.Should().Be("{\"rpgName\":\"v11\"}");
    }
}
