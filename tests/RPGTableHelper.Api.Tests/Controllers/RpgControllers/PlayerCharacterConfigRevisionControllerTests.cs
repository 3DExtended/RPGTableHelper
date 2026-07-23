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

public class PlayerCharacterConfigRevisionControllerTests : ControllerTestBase
{
    public PlayerCharacterConfigRevisionControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task PatchPlayerCharacterRpgConfigAsync_ShouldApplyPatchWhenRevisionMatches()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"old\"}",
            RpgCharacterConfigurationRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/characterName\",\"value\":\"new\"}]",
        };

        // act
        var response = await Client.PatchAsJsonAsync(
            $"/PlayerCharacter/patchcharacterconfig/{entity.Id}",
            patchRequest
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigWriteResultDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Revision.Should().Be(2);

        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.PlayerCharacters.SingleAsync(c => c.Id == entity.Id);
            stored.RpgCharacterConfiguration.Should().Be("{\"characterName\":\"new\"}");
            stored.RpgCharacterConfigurationRevision.Should().Be(2);
        }
    }

    [Fact]
    public async Task PatchPlayerCharacterRpgConfigAsync_ShouldReturnConflictWhenFromRevisionIsStale()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"old\"}",
            RpgCharacterConfigurationRevision = 5,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        var patchRequest = new ConfigPatchRequestDto
        {
            FromRevision = 1,
            Patch = "[{\"op\":\"replace\",\"path\":\"/characterName\",\"value\":\"new\"}]",
        };

        // act
        var response = await Client.PatchAsJsonAsync(
            $"/PlayerCharacter/patchcharacterconfig/{entity.Id}",
            patchRequest
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.PlayerCharacters.SingleAsync(c => c.Id == entity.Id);
            stored.RpgCharacterConfiguration.Should().Be("{\"characterName\":\"old\"}");
            stored.RpgCharacterConfigurationRevision.Should().Be(5);
        }
    }

    [Fact]
    public async Task GetPlayerCharacterRpgConfigAsync_ShouldReturnFullWhenNoSinceRevisionProvided()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"old\"}",
            RpgCharacterConfigurationRevision = 3,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.GetAsync($"/PlayerCharacter/getplayercharacterconfig/{entity.Id}");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Kind.Should().Be("full");
        responseParsed.Revision.Should().Be(3);
        responseParsed.FullConfig.Should().Be("{\"characterName\":\"old\"}");
    }

    [Fact]
    public async Task GetPlayerCharacterRpgConfigAsync_ShouldReturnPatchWhenSinceRevisionHasHistorySnapshot()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"old\"}",
            RpgCharacterConfigurationRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // Patch once so a history snapshot for revision 2 exists and becomes the new current state.
        var patchResponse = await Client.PatchAsJsonAsync(
            $"/PlayerCharacter/patchcharacterconfig/{entity.Id}",
            new ConfigPatchRequestDto
            {
                FromRevision = 1,
                Patch = "[{\"op\":\"replace\",\"path\":\"/characterName\",\"value\":\"new\"}]",
            }
        );
        patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // act
        var response = await Client.GetAsync(
            $"/PlayerCharacter/getplayercharacterconfig/{entity.Id}?sinceRevision=2"
        );

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
    public async Task GetPlayerCharacterRpgConfigAsync_ShouldReturnFullWhenSinceRevisionIsOlderThanHistoryWindow()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"v0\"}",
            RpgCharacterConfigurationRevision = 1,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // Apply 11 patches so the revision-2 snapshot falls outside the 10-snapshot history window.
        for (var i = 0; i < 11; i++)
        {
            var patchResponse = await Client.PatchAsJsonAsync(
                $"/PlayerCharacter/patchcharacterconfig/{entity.Id}",
                new ConfigPatchRequestDto
                {
                    FromRevision = i + 1,
                    Patch = $"[{{\"op\":\"replace\",\"path\":\"/characterName\",\"value\":\"v{i + 1}\"}}]",
                }
            );
            patchResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        }

        // act
        var response = await Client.GetAsync(
            $"/PlayerCharacter/getplayercharacterconfig/{entity.Id}?sinceRevision=2"
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseParsed = await response.Content.ReadFromJsonAsync<ConfigSnapshotResponseDto>();
        responseParsed.Should().NotBeNull();
        responseParsed!.Kind.Should().Be("full");
        responseParsed.Revision.Should().Be(12);
        responseParsed.FullConfig.Should().Be("{\"characterName\":\"v11\"}");
    }

    [Fact]
    public async Task UpdatePlayerCharacterRpgConfigAsync_ShouldReturnConflictWhenFromRevisionProvidedAndStale()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var entity = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "CharacterName1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "{\"characterName\":\"old\"}",
            RpgCharacterConfigurationRevision = 5,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(entity);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.PutAsJsonAsync(
            $"/PlayerCharacter/updatecharacterconfig/{entity.Id}",
            new PlayerCharacterUpdateRpgConfigDto
            {
                RpgCharacterConfiguration = "{\"characterName\":\"hacked\"}",
                FromRevision = 1,
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var stored = await context.PlayerCharacters.SingleAsync(c => c.Id == entity.Id);
            stored.RpgCharacterConfiguration.Should().Be("{\"characterName\":\"old\"}");
            stored.RpgCharacterConfigurationRevision.Should().Be(5);
        }
    }
}
