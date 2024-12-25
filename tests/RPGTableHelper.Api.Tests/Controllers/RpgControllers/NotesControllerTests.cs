using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using Xunit;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class NotesControllerTests : ControllerTestBase
{
    public NotesControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task UpdateNoteAsync_ShouldReturnUnauthorizedIfJwtInvalid()
    {
        // arrange
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "invalid_jwt_token");

        // act
        var response = await Client.PutAsJsonAsync(
            "/notes/updatenote",
            new NoteDocumentDto
            {
                Id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid()),
                Title = "UpdatedTitle",
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task UpdateNoteAsync_ShouldReturnBadRequestIfDocumentNotFound()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        // act
        var response = await Client.PutAsJsonAsync(
            "/notes/updatenote",
            new NoteDocumentDto
            {
                Id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid()),
                Title = "UpdatedTitle",
                GroupName = "GroupName",
                CreatedForCampagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid()),
                CreatingUserId = User.UserIdentifier.From(Guid.NewGuid()),
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var responseContent = await response.Content.ReadAsStringAsync();
        responseContent.Should().Contain("Could not retrieve NoteDocument");
    }

    [Fact]
    public async Task UpdateNoteAsync_ShouldReturnUnauthorizedIfUserIsNotOwner()
    {
        // arrange
        var user = await ConfigureLoggedInUser();
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "User2");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

        var noteDocument = new NoteDocumentEntity
        {
            Id = Guid.NewGuid(),
            Title = "OriginalTitle",
            GroupName = "GroupName",
            CreatingUserId = user2.Id.Value,
            CreatedForCampagneId = campagne.Id.Value,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.CampagneDocuments.AddAsync(noteDocument);
            await context.SaveChangesAsync();
        }

        // act
        var response = await Client.PutAsJsonAsync(
            "/notes/updatenote",
            new NoteDocumentDto
            {
                Id = NoteDocument.NoteDocumentIdentifier.From(noteDocument.Id),
                Title = "UpdatedTitle",
                GroupName = "GroupName",

                CreatedForCampagneId = campagne.Id,
                CreatingUserId = user2.Id,
            }
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task UpdateNoteAsync_ShouldBeSuccessful()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

        var noteDocument = new NoteDocumentEntity
        {
            Id = Guid.NewGuid(),
            Title = "OriginalTitle",
            CreatingUserId = user.Id.Value,
            GroupName = "GroupName",
            CreatedForCampagneId = campagne.Id.Value,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.CampagneDocuments.AddAsync(noteDocument);
            await context.SaveChangesAsync();
        }

        var updatedNoteDocumentDto = new NoteDocumentDto
        {
            Id = NoteDocument.NoteDocumentIdentifier.From(noteDocument.Id),
            Title = "UpdatedTitle",
            GroupName = "GroupName",

            CreatedForCampagneId = campagne.Id,
            CreatingUserId = user.Id,
        };

        // act
        var response = await Client.PutAsJsonAsync("/notes/updatenote", updatedNoteDocumentDto);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var updatedNoteDocument = await context.CampagneDocuments.FindAsync(noteDocument.Id);
            updatedNoteDocument.Should().NotBeNull();
            updatedNoteDocument!.Title.Should().Be("UpdatedTitle");
        }
    }

    [Fact]
    public async Task UpdateNoteAsync_ShouldUpdateGroupNameSuccessfully()
    {
        // arrange
        var user = await ConfigureLoggedInUser();

        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

        var noteDocument = new NoteDocumentEntity
        {
            Id = Guid.NewGuid(),
            Title = "OriginalTitle",
            CreatingUserId = user.Id.Value,
            GroupName = "OriginalGroupName",
            CreatedForCampagneId = campagne.Id.Value,
        };

        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.CampagneDocuments.AddAsync(noteDocument);
            await context.SaveChangesAsync();
        }

        var updatedNoteDocumentDto = new NoteDocumentDto
        {
            Id = NoteDocument.NoteDocumentIdentifier.From(noteDocument.Id),
            Title = "UpdatedTitle",
            GroupName = "UpdatedGroupName",

            CreatedForCampagneId = campagne.Id,
            CreatingUserId = user.Id,
        };

        // act
        var response = await Client.PutAsJsonAsync("/notes/updatenote", updatedNoteDocumentDto);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using (var context = ContextFactory!.CreateDbContext())
        {
            var updatedNoteDocument = await context.CampagneDocuments.FindAsync(noteDocument.Id);
            updatedNoteDocument.Should().NotBeNull();
            updatedNoteDocument!.GroupName.Should().Be("UpdatedGroupName");
        }
    }
}
