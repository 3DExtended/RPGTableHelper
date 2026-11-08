using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteDocumentsSetGroupQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_MovesEveryDocumentIntoTheGroup()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var first = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var second = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var untouched = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var subjectUnderTest = new NoteDocumentsSetGroupQueryHandler(ContextFactory);

        // act
        var result = await subjectUnderTest.RunQueryAsync(
            new NoteDocumentsSetGroupQuery { DocumentIds = new[] { first.Id, second.Id }, GroupName = "Town" },
            default
        );

        // assert
        result.IsSome.Should().BeTrue();
        var groups = Context.CampagneDocuments.AsNoTracking().ToDictionary(d => d.Id, d => d.GroupName);
        groups[first.Id.Value].Should().Be("Town");
        groups[second.Id.Value].Should().Be("Town");
        groups[untouched.Id.Value].Should().Be("asdf");
    }

    [Fact]
    public async Task RunQueryAsync_WithAnUnknownDocument_MovesNothing()
    {
        // arrange
        var owner = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, owner);
        var document = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, owner, campagne);
        var subjectUnderTest = new NoteDocumentsSetGroupQueryHandler(ContextFactory);

        // act
        var result = await subjectUnderTest.RunQueryAsync(
            new NoteDocumentsSetGroupQuery
            {
                DocumentIds = new[] { document.Id, NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid()) },
                GroupName = "Town",
            },
            default
        );

        // assert
        result.IsNone.Should().BeTrue();
        Context.CampagneDocuments.AsNoTracking().Single().GroupName.Should().Be("asdf");
    }
}
