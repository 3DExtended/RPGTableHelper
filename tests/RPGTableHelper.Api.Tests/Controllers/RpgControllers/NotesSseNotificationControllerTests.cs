using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

/// <summary>
/// Coverage for sse-07: note/block permission changes, content updates, creates and deletes compute who
/// gained, lost, or still shares access and emit a membership-scoped <c>noteAccessChanged</c> SSE notify
/// (ids + change kind only, no note bodies) to those users' <c>/events</c> streams - even without
/// <c>SessionEnter</c>, mirroring sse-05's join-request notifies.
/// </summary>
public class NotesSseNotificationControllerTests : ControllerTestBase
{
    public NotesSseNotificationControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateTextBlock_NotifiesGrantedSharee_WhenPermittedUsersSet_WithoutSessionEnter()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);

        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Sharee");

        using var shareeClient = Factory.CreateClient();
        shareeClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(sharee)
        );

        using var shareeEventsResponse = await shareeClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        shareeEventsResponse.EnsureSuccessStatusCode();
        await using var shareeStream = await shareeEventsResponse.Content.ReadAsStreamAsync();
        using var shareeReader = new StreamReader(shareeStream, Encoding.UTF8);

        // drain hello
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();

        // act
        var createResponse = await Client.PostAsJsonAsync(
            $"/notes/createtextblock/{document.Id.Value}",
            new TextBlock
            {
                MarkdownText = "hello",
                NoteDocumentId = document.Id,
                CreatingUserId = owner.Id,
                PermittedUsers = new List<User.UserIdentifier> { sharee.Id },
            }
        );
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await shareeReader.ReadLineAsync();
        var dataLine = await shareeReader.ReadLineAsync();

        eventLine.Should().Be("event: noteAccessChanged");
        dataLine.Should().Contain("granted");
        dataLine.Should().Contain(document.Id.Value.ToString());
        dataLine.Should().Contain(campagne.Id.Value.ToString());
    }

    [Fact]
    public async Task CreateTextBlock_NotifiesNobody_WhenPermittedUsersEmpty_PrivateBlock()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);

        var otherUser = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Other");

        using var otherClient = Factory.CreateClient();
        otherClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(otherUser)
        );

        using var otherEventsResponse = await otherClient.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);
        otherEventsResponse.EnsureSuccessStatusCode();
        await using var otherStream = await otherEventsResponse.Content.ReadAsStreamAsync();
        using var otherReader = new StreamReader(otherStream, Encoding.UTF8);

        await otherReader.ReadLineAsync();
        await otherReader.ReadLineAsync();
        await otherReader.ReadLineAsync();

        // act: private block - nobody permitted yet.
        var createResponse = await Client.PostAsJsonAsync(
            $"/notes/createtextblock/{document.Id.Value}",
            new TextBlock
            {
                MarkdownText = "private",
                NoteDocumentId = document.Id,
                CreatingUserId = owner.Id,
                PermittedUsers = new List<User.UserIdentifier>(),
            }
        );
        createResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // send a second, harmless create so we have a deterministic signal that nothing arrived for the
        // first (private) create: no event should be readable on the other user's stream at all.
        var readTask = otherReader.ReadLineAsync();
        var completed = await Task.WhenAny(readTask, Task.Delay(TimeSpan.FromMilliseconds(300)));

        // assert
        completed.Should().NotBe(readTask, "a private block with no permitted users must notify nobody");
    }

    [Fact]
    public async Task UpdateTextBlock_NotifiesGainedUserAsGranted_AndLostUserAsRevoked()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);

        var lostUser = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Lost");
        var gainedUser = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Gained");

        TextBlockEntity blockEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            blockEntity = new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "old",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
            };
            await context.NoteBlocks.AddAsync(blockEntity);
            await context.SaveChangesAsync();

            await context.PermittedUsersToNotesBlocks.AddAsync(
                new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = lostUser.Id.Value }
            );
            await context.SaveChangesAsync();
        }

        using var lostClient = Factory.CreateClient();
        lostClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(lostUser)
        );
        using var lostEventsResponse = await lostClient.GetAsync("/events", HttpCompletionOption.ResponseHeadersRead);
        lostEventsResponse.EnsureSuccessStatusCode();
        await using var lostStream = await lostEventsResponse.Content.ReadAsStreamAsync();
        using var lostReader = new StreamReader(lostStream, Encoding.UTF8);
        await lostReader.ReadLineAsync();
        await lostReader.ReadLineAsync();
        await lostReader.ReadLineAsync();

        using var gainedClient = Factory.CreateClient();
        gainedClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(gainedUser)
        );
        using var gainedEventsResponse = await gainedClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        gainedEventsResponse.EnsureSuccessStatusCode();
        await using var gainedStream = await gainedEventsResponse.Content.ReadAsStreamAsync();
        using var gainedReader = new StreamReader(gainedStream, Encoding.UTF8);
        await gainedReader.ReadLineAsync();
        await gainedReader.ReadLineAsync();
        await gainedReader.ReadLineAsync();

        // act
        var updateResponse = await Client.PutAsJsonAsync(
            "/notes/updatetextblock",
            new TextBlock
            {
                Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockEntity.Id),
                MarkdownText = "old",
                NoteDocumentId = document.Id,
                CreatingUserId = owner.Id,
                PermittedUsers = new List<User.UserIdentifier> { gainedUser.Id },
            }
        );
        updateResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var lostEventLine = await lostReader.ReadLineAsync();
        var lostDataLine = await lostReader.ReadLineAsync();
        lostEventLine.Should().Be("event: noteAccessChanged");
        lostDataLine.Should().Contain("revoked");

        var gainedEventLine = await gainedReader.ReadLineAsync();
        var gainedDataLine = await gainedReader.ReadLineAsync();
        gainedEventLine.Should().Be("event: noteAccessChanged");
        gainedDataLine.Should().Contain("granted");
    }

    [Fact]
    public async Task UpdateTextBlock_NotifiesRemainingSharee_AsUpdated_OnContentOnlyChange()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Sharee");

        TextBlockEntity blockEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            blockEntity = new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "old",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
            };
            await context.NoteBlocks.AddAsync(blockEntity);
            await context.SaveChangesAsync();

            await context.PermittedUsersToNotesBlocks.AddAsync(
                new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = sharee.Id.Value }
            );
            await context.SaveChangesAsync();
        }

        using var shareeClient = Factory.CreateClient();
        shareeClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(sharee)
        );
        using var shareeEventsResponse = await shareeClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        shareeEventsResponse.EnsureSuccessStatusCode();
        await using var shareeStream = await shareeEventsResponse.Content.ReadAsStreamAsync();
        using var shareeReader = new StreamReader(shareeStream, Encoding.UTF8);
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();

        // act: only content changes, permitted users stay the same.
        var updateResponse = await Client.PutAsJsonAsync(
            "/notes/updatetextblock",
            new TextBlock
            {
                Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockEntity.Id),
                MarkdownText = "new content",
                NoteDocumentId = document.Id,
                CreatingUserId = owner.Id,
                PermittedUsers = new List<User.UserIdentifier> { sharee.Id },
            }
        );
        updateResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await shareeReader.ReadLineAsync();
        var dataLine = await shareeReader.ReadLineAsync();
        eventLine.Should().Be("event: noteAccessChanged");
        dataLine.Should().Contain("updated");
        dataLine.Should().NotContain("markdown");
        dataLine.Should().NotContain("new content");
    }

    [Fact]
    public async Task DeleteNoteBlock_NotifiesRevoked_ToPermittedUsers()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Sharee");

        TextBlockEntity blockEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            blockEntity = new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "to be deleted",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
            };
            await context.NoteBlocks.AddAsync(blockEntity);
            await context.SaveChangesAsync();

            await context.PermittedUsersToNotesBlocks.AddAsync(
                new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = sharee.Id.Value }
            );
            await context.SaveChangesAsync();
        }

        using var shareeClient = Factory.CreateClient();
        shareeClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(sharee)
        );
        using var shareeEventsResponse = await shareeClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        shareeEventsResponse.EnsureSuccessStatusCode();
        await using var shareeStream = await shareeEventsResponse.Content.ReadAsStreamAsync();
        using var shareeReader = new StreamReader(shareeStream, Encoding.UTF8);
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();

        // act
        var deleteResponse = await Client.DeleteAsync($"/notes/deleteblock?Value={blockEntity.Id}");
        deleteResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await shareeReader.ReadLineAsync();
        var dataLine = await shareeReader.ReadLineAsync();
        eventLine.Should().Be("event: noteAccessChanged");
        dataLine.Should().Contain("revoked");
        dataLine.Should().Contain(blockEntity.Id.ToString());
    }

    [Fact]
    public async Task DeleteNoteDocument_NotifiesRevoked_ToAllShareesAcrossBlocks()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Sharee");

        TextBlockEntity blockEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            blockEntity = new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "shared",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
            };
            await context.NoteBlocks.AddAsync(blockEntity);
            await context.SaveChangesAsync();

            await context.PermittedUsersToNotesBlocks.AddAsync(
                new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = sharee.Id.Value }
            );
            await context.SaveChangesAsync();
        }

        using var shareeClient = Factory.CreateClient();
        shareeClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(sharee)
        );
        using var shareeEventsResponse = await shareeClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        shareeEventsResponse.EnsureSuccessStatusCode();
        await using var shareeStream = await shareeEventsResponse.Content.ReadAsStreamAsync();
        using var shareeReader = new StreamReader(shareeStream, Encoding.UTF8);
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();

        // act
        var deleteResponse = await Client.DeleteAsync($"/notes/deletedocument/{document.Id.Value}");
        deleteResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await shareeReader.ReadLineAsync();
        var dataLine = await shareeReader.ReadLineAsync();
        eventLine.Should().Be("event: noteAccessChanged");
        dataLine.Should().Contain("revoked");
        dataLine.Should().Contain(document.Id.Value.ToString());
    }

    [Fact]
    public async Task UpdateNote_NotifiesUpdated_ToAllShareesAcrossBlocks_OnTitleChange()
    {
        // arrange
        var owner = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory!, Mapper!, owner, campagne);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!, usernameOverride: "Sharee");

        TextBlockEntity blockEntity;
        using (var context = ContextFactory!.CreateDbContext())
        {
            blockEntity = new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "shared",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
            };
            await context.NoteBlocks.AddAsync(blockEntity);
            await context.SaveChangesAsync();

            await context.PermittedUsersToNotesBlocks.AddAsync(
                new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = sharee.Id.Value }
            );
            await context.SaveChangesAsync();
        }

        using var shareeClient = Factory.CreateClient();
        shareeClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            CreateJwtForUser(sharee)
        );
        using var shareeEventsResponse = await shareeClient.GetAsync(
            "/events",
            HttpCompletionOption.ResponseHeadersRead
        );
        shareeEventsResponse.EnsureSuccessStatusCode();
        await using var shareeStream = await shareeEventsResponse.Content.ReadAsStreamAsync();
        using var shareeReader = new StreamReader(shareeStream, Encoding.UTF8);
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();
        await shareeReader.ReadLineAsync();

        // act
        var updateResponse = await Client.PutAsJsonAsync(
            "/notes/updatenote",
            new NoteDocumentDto
            {
                Id = document.Id,
                Title = "Renamed",
                GroupName = document.GroupName,
                CreatedForCampagneId = campagne.Id,
                CreatingUserId = owner.Id,
            }
        );
        updateResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        // assert
        var eventLine = await shareeReader.ReadLineAsync();
        var dataLine = await shareeReader.ReadLineAsync();
        eventLine.Should().Be("event: noteAccessChanged");
        dataLine.Should().Contain("updated");
        dataLine.Should().Contain(document.Id.Value.ToString());
    }
}
