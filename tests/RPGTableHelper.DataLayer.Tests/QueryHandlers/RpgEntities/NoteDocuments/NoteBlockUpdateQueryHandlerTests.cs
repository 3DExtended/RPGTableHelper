﻿using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.NoteDocuments;

public class NoteBlockUpdateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_UpdatesImageBlockEntityCorrectly()
    {
        // Arrange
        var user1 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, user1);
        var someImage = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory, Mapper, user1, campagne);
        var someImage2 = await RpgDbContextHelpers.CreateIamgeMetaDataInDb(ContextFactory, Mapper, user1, campagne);
        var someDocument = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, user1, campagne);

        var entity1 = new ImageBlockEntity
        {
            Id = Guid.Empty,
            PublicImageUrl = "Bar",
            ImageMetaDataId = someImage.Id.Value,
            CreatingUserId = user1.Id.Value,
            NoteDocumentId = someDocument.Id.Value,
            Visibility = NotesBlockVisibility.VisibleForCampagne,
        };

        var entity2 = new ImageBlockEntity
        {
            Id = Guid.Empty,
            PublicImageUrl = "Bar",
            ImageMetaDataId = someImage2.Id.Value,
            CreatingUserId = user1.Id.Value,
            NoteDocumentId = someDocument.Id.Value,
            Visibility = NotesBlockVisibility.VisibleForCampagne,
        };

        Context.NoteBlocks.Add(entity1);
        Context.NoteBlocks.Add(entity2);
        Context.SaveChanges();

        var query = new NoteBlockUpdateQuery
        {
            UpdatedModel = new ImageBlock()
            {
                Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(entity2.Id),
                PublicImageUrl = "Foo",
                Visibility = NotesBlockVisibility.HiddenForAllExceptAuthor,
                ImageMetaDataId = someImage.Id,
                CreatingUserId = user1.Id,
                NoteDocumentId = someDocument.Id,
            },
        };
        var subjectUnderTest = new NoteBlockUpdateQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the update should be successful");
        var entityCount = Context.NoteBlocks.Count();
        entityCount.Should().Be(2);

        var updatedEntity = Context.NoteBlocks.AsNoTracking().First(x => x.Id == entity2.Id);
        updatedEntity!.Should().BeOfType<ImageBlockEntity>();
        updatedEntity!.As<ImageBlockEntity>().Visibility.Should().Be(NotesBlockVisibility.HiddenForAllExceptAuthor);
        updatedEntity!.As<ImageBlockEntity>().PublicImageUrl.Should().Be("Foo");
    }

    [Fact]
    public async Task RunQueryAsync_UpdatesTextBlockEntityCorrectly()
    {
        // Arrange
        var user1 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory, Mapper, user1);
        var someDocument = await RpgDbContextHelpers.CreateNoteDocumentInDb(ContextFactory, Mapper, user1, campagne);

        var entity1 = new TextBlockEntity
        {
            Id = Guid.Empty,
            MarkdownText = "Bar",
            CreatingUserId = user1.Id.Value,
            NoteDocumentId = someDocument.Id.Value,
            Visibility = NotesBlockVisibility.VisibleForCampagne,
        };

        var entity2 = new TextBlockEntity
        {
            Id = Guid.Empty,
            MarkdownText = "Bar",
            CreatingUserId = user1.Id.Value,
            NoteDocumentId = someDocument.Id.Value,
            Visibility = NotesBlockVisibility.VisibleForCampagne,
        };

        Context.NoteBlocks.Add(entity1);
        Context.NoteBlocks.Add(entity2);
        Context.SaveChanges();

        var query = new NoteBlockUpdateQuery
        {
            UpdatedModel = new TextBlock()
            {
                Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(entity2.Id),
                MarkdownText = "Foo",
                Visibility = NotesBlockVisibility.HiddenForAllExceptAuthor,
                CreatingUserId = user1.Id,
                NoteDocumentId = someDocument.Id,
            },
        };
        var subjectUnderTest = new NoteBlockUpdateQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the update should be successful");
        var entityCount = Context.NoteBlocks.Count();
        entityCount.Should().Be(2);

        var updatedEntity = Context.NoteBlocks.AsNoTracking().First(x => x.Id == entity2.Id);
        updatedEntity!.Should().BeOfType<TextBlockEntity>();
        updatedEntity!.As<TextBlockEntity>().Visibility.Should().Be(NotesBlockVisibility.HiddenForAllExceptAuthor);
        updatedEntity!.As<TextBlockEntity>().MarkdownText.Should().Be("Foo");
    }
}
