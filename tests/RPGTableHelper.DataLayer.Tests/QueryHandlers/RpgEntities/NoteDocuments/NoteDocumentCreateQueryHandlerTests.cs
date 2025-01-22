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

public class NoteDocumentCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, user);
        var someImage = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory, Mapper, user, campagne);

        var query = new NoteDocumentCreateQuery
        {
            ModelToCreate = new NoteDocument
            {
                Id = NoteDocument.NoteDocumentIdentifier.From(Guid.Empty),
                GroupName = "Götter",
                Title = "Skardi",
                CreatedForCampagneId = campagne.Id,
                CreatingUserId = user.Id,
                NoteBlocks = new List<NoteBlockModelBase>
                {
                    new ImageBlock
                    {
                        CreatingUserId = user.Id,
                        ImageMetaDataId = someImage.Id,
                        PublicImageUrl = "asdf",
                    },
                    new TextBlock
                    {
                        CreatingUserId = user.Id,

                        MarkdownText = "# Hello world",
                    },
                },
            },
        };

        var subjectUnderTest = new NoteDocumentCreateQueryHandler(ContextFactory, Mapper, QueryProcessor);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        Context.CampagneDocuments.Count().Should().Be(1);
        var document = Context.CampagneDocuments.First();
        document.Id.Should().NotBe(Guid.Empty);
        document.CreatedForCampagneId.Should().Be(campagne.Id.Value);
        document.CreatingUserId.Should().Be(user.Id.Value);
        document.Title.Should().Be("Skardi");
        document.GroupName.Should().Be("Götter");

        Context.NoteBlocks.Count().Should().Be(2);

        var blocks = Context.NoteBlocks.ToList();
        blocks.Count(e => e is ImageBlockEntity).Should().Be(1);
        blocks.Count(e => e is TextBlockEntity).Should().Be(1);

        blocks.Single(e => e is ImageBlockEntity).As<ImageBlockEntity>().PublicImageUrl.Should().Be("asdf");
        blocks
            .Single(e => e is ImageBlockEntity)
            .As<ImageBlockEntity>()
            .ImageMetaDataId.Should()
            .Be(someImage.Id.Value);

        blocks.Single(e => e is TextBlockEntity).As<TextBlockEntity>().MarkdownText.Should().Be("# Hello world");
    }
}
