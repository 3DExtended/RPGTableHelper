using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using NSubstitute;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlockCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_PersistsPermittedUsers_WhenCreatingSharedBlock()
    {
        // arrange: sse-07 needs permitted-user diffs to work off what was actually persisted on create,
        // not just what was requested in the DTO.
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "Sharee");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);

        var query = new NoteBlockCreateQuery
        {
            ModelToCreate = new TextBlock
            {
                CreatingUserId = owner.Id,
                NoteDocumentId = document.Id,
                MarkdownText = "shared content",
                PermittedUsers = new List<User.UserIdentifier> { sharee.Id },
            },
        };

        var subjectUnderTest = new NoteBlockCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var persistedBlock = await Context
            .NoteBlocks.Include(b => b.PermittedUsers)
            .AsNoTracking()
            .FirstAsync(b => b.Id == result.Get().Value);

        persistedBlock.PermittedUsers.Should().HaveCount(1);
        persistedBlock.PermittedUsers.First().PermittedUserId.Should().Be(sharee.Id.Value);
    }

    [Fact]
    public async Task RunQueryAsync_PersistsNoPermittedUsers_WhenCreatingPrivateBlock()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);

        var query = new NoteBlockCreateQuery
        {
            ModelToCreate = new TextBlock
            {
                CreatingUserId = owner.Id,
                NoteDocumentId = document.Id,
                MarkdownText = "private content",
                PermittedUsers = new List<User.UserIdentifier>(),
            },
        };

        var subjectUnderTest = new NoteBlockCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // assert
        result.IsSome.Should().BeTrue("because the creation should be successful");
        Context.PermittedUsersToNotesBlocks.Count().Should().Be(0);
    }

    [Fact]
    public async Task RunQueryAsync_InADocumentThatWasNeverArranged_LeavesThePositionEmpty()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var subjectUnderTest = new NoteBlockCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // act
        var result = await subjectUnderTest.RunQueryAsync(NewTextBlock(owner, document, sortIndex: 7), default);

        // assert
        Context.NoteBlocks.AsNoTracking().Single(b => b.Id == result.Get().Value).SortIndex.Should().BeNull();
    }

    [Fact]
    public async Task RunQueryAsync_InAnArrangedDocument_PutsTheBlockLast_AndChangesTheDocument()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        Context.NoteBlocks.Add(
            new TextBlockEntity
            {
                Id = Guid.NewGuid(),
                MarkdownText = "arranged",
                CreatingUserId = owner.Id.Value,
                NoteDocumentId = document.Id.Value,
                SortIndex = 4,
            }
        );
        Context.SaveChanges();
        var later = new DateTimeOffset(2024, 03, 03, 9, 0, 0, TimeSpan.Zero);
        SystemClock.Now.Returns(later);
        var subjectUnderTest = new NoteBlockCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // act
        var result = await subjectUnderTest.RunQueryAsync(NewTextBlock(owner, document, sortIndex: 0), default);

        // assert
        Context.NoteBlocks.AsNoTracking().Single(b => b.Id == result.Get().Value).SortIndex.Should().Be(5);
        Context.CampagneDocuments.AsNoTracking().Single(d => d.Id == document.Id.Value).LastModifiedAt.Should().Be(later);
    }

    private static NoteBlockCreateQuery NewTextBlock(User owner, NoteDocument document, int? sortIndex) =>
        new()
        {
            ModelToCreate = new TextBlock
            {
                CreatingUserId = owner.Id,
                NoteDocumentId = document.Id,
                MarkdownText = "new",
                SortIndex = sortIndex,
                PermittedUsers = new List<User.UserIdentifier>(),
            },
        };
}
