using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlockQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_IncludesPermittedUsers()
    {
        // arrange: sse-07's create/update/delete notify logic diffs off the permitted users returned by
        // this query, so it must actually load them (previously missing an `.Include(...)`).
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var sharee = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "Sharee");
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);

        var blockEntity = new TextBlockEntity
        {
            Id = Guid.NewGuid(),
            MarkdownText = "shared",
            CreatingUserId = owner.Id.Value,
            NoteDocumentId = document.Id.Value,
        };
        Context.NoteBlocks.Add(blockEntity);
        await Context.SaveChangesAsync();

        Context.PermittedUsersToNotesBlocks.Add(
            new PermittedUsersToNotesBlockEntity { NotesBlockId = blockEntity.Id, PermittedUserId = sharee.Id.Value }
        );
        await Context.SaveChangesAsync();

        var subjectUnderTest = new NoteBlockQueryHandler(Mapper, ContextFactory);

        // act
        var result = await subjectUnderTest.RunQueryAsync(
            new NoteBlockQuery { ModelId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(blockEntity.Id) },
            default
        );

        // assert
        result.IsSome.Should().BeTrue();
        result.Get().PermittedUsers.Should().HaveCount(1);
        result.Get().PermittedUsers.Single().Value.Should().Be(sharee.Id.Value);
    }
}
