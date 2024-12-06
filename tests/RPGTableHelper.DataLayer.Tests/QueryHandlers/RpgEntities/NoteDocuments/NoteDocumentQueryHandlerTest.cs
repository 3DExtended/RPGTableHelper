using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteDocumentQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, user);
        var someImage = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory, Mapper, user, campagne);
        var user2 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "asdf2");
        var user3 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper, usernameOverride: "asdf3");

        List<NoteDocumentEntity> entities =
            new()
            {
                new NoteDocumentEntity
                {
                    Id = Guid.Empty,
                    GroupName = "Bla1",
                    CreatingUserId = user.Id.Value,
                    Title = "SomeTitle1",
                    CreatedForCampagneId = campagne.Id.Value,
                },
                new NoteDocumentEntity
                {
                    Id = Guid.Empty,
                    GroupName = "Bla2",
                    CreatingUserId = user.Id.Value,
                    Title = "SomeTitle2",
                    CreatedForCampagneId = campagne.Id.Value,
                },
                new NoteDocumentEntity
                {
                    Id = Guid.Empty,
                    GroupName = "Bla3",
                    CreatingUserId = user.Id.Value,
                    Title = "SomeTitle3",
                    CreatedForCampagneId = campagne.Id.Value,
                },
            };

        Context.CampagneDocuments.AddRange(entities);
        Context.SaveChanges();

        // create some notes underneath those documents to see if they are getting read correctly
        var noteBlockText = new TextBlockEntity
        {
            MarkdownText = "# Some text\nasdf asdf asdf asdf asdf",
            CreatingUserId = user.Id.Value,
            Visibility = NotesBlockVisibility.VisibleForCampagne,
        };

        var noteBlockImage = new ImageBlockEntity
        {
            ImageMetaDataId = someImage.Id.Value,
            PublicImageUrl = "asdf/asdf",
            CreatingUserId = user.Id.Value,
            Visibility = NotesBlockVisibility.HiddenForAllExceptAuthor,
        };

        for (int i = 0; i < 2; i++)
        {
            NoteDocumentEntity? entity = entities[i];
            noteBlockText.Id = Guid.Empty;
            noteBlockText.NoteDocumentId = entity.Id;
            Context.NoteBlocks.Add(noteBlockText);

            noteBlockImage.Id = Guid.Empty;
            noteBlockImage.NoteDocumentId = entity.Id;

            Context.NoteBlocks.Add(noteBlockImage);

            Context.SaveChanges();
        }

        Context.PermittedUsersToNotesBlocks.AddRange(
            new List<PermittedUsersToNotesBlock>
            {
                new PermittedUsersToNotesBlock
                {
                    PermittedUserId = user2.Id.Value,
                    Id = 0,
                    NotesBlockId = noteBlockText.Id,
                },
                new PermittedUsersToNotesBlock
                {
                    PermittedUserId = user3.Id.Value,
                    Id = 0,
                    NotesBlockId = noteBlockText.Id,
                },
            }
        );

        Context.PermittedUsersToNotesBlocks.AddRange(
            new List<PermittedUsersToNotesBlock>
            {
                new PermittedUsersToNotesBlock
                {
                    PermittedUserId = user2.Id.Value,
                    Id = 0,
                    NotesBlockId = noteBlockImage.Id,
                },
                new PermittedUsersToNotesBlock
                {
                    PermittedUserId = user3.Id.Value,
                    Id = 0,
                    NotesBlockId = noteBlockImage.Id,
                },
            }
        );
        Context.SaveChanges();

        var query = new NoteDocumentQuery { ModelId = NoteDocument.NoteDocumentIdentifier.From(entities[1].Id) };
        var subjectUnderTest = new NoteDocumentQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Id.Should().Be(NoteDocument.NoteDocumentIdentifier.From(entities[1].Id));
        result.Get().Title.Should().Be(entities[1].Title);
        result.Get().GroupName.Should().Be(entities[1].GroupName);
        result.Get().NoteBlocks.Count.Should().Be(2);
        result.Get().NoteBlocks.Count(block => block is TextBlock).Should().Be(1);
        result.Get().NoteBlocks.Count(block => block is ImageBlock).Should().Be(1);

        var textBlock = result.Get().NoteBlocks.First(block => block is TextBlock);
        textBlock.NoteDocumentId.Value.Should().Be(entities[1].Id);
        textBlock.Visibility.Should().Be(NotesBlockVisibility.VisibleForCampagne);
        (textBlock as TextBlock)!.MarkdownText.Should().Be(noteBlockText.MarkdownText);
        textBlock.PermittedUsers.Count().Should().Be(2);

        var imageBlock = result.Get().NoteBlocks.First(block => block is ImageBlock);
        imageBlock.NoteDocumentId.Value.Should().Be(entities[1].Id);
        imageBlock.Visibility.Should().Be(NotesBlockVisibility.HiddenForAllExceptAuthor);
        (imageBlock as ImageBlock)!.PublicImageUrl.Should().Be(noteBlockImage.PublicImageUrl);
        imageBlock.PermittedUsers.Count().Should().Be(2);
    }
}
