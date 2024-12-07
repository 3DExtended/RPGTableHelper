using System;
using System.Collections.Generic;
using AutoMapper;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.WebApi.Dtos.RpgEntities;
using RPGTableHelper.WebApi.Services;
using Xunit;

namespace RPGTableHelper.Api.Tests
{
    public class ApiDtoMapperProfileTests
    {
        private readonly IMapper _mapper;

        public ApiDtoMapperProfileTests()
        {
            var config = new MapperConfiguration(cfg =>
            {
                cfg.AddProfile<ApiDtoMapperProfile>();
            });

            _mapper = config.CreateMapper();
        }

        [Fact]
        public void DtoToModelShould_Map_GroupName()
        {
            // Arrange
            var dto = new NoteDocumentDto { GroupName = "Test Group" };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.GroupName, result.GroupName);
        }

        [Fact]
        public void DtoToModelShould_Map_CreatingUserId()
        {
            // Arrange
            var creatingUserId = User.UserIdentifier.From(Guid.NewGuid());
            var dto = new NoteDocumentDto { CreatingUserId = creatingUserId };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.CreatingUserId, result.CreatingUserId);
        }

        [Fact]
        public void DtoToModelShould_Map_Title()
        {
            // Arrange
            var dto = new NoteDocumentDto { Title = "Test Title" };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.Title, result.Title);
        }

        [Fact]
        public void DtoToModelShould_Map_CreatedForCampagneId()
        {
            // Arrange
            var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
            var dto = new NoteDocumentDto { CreatedForCampagneId = campagneId };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.CreatedForCampagneId, result.CreatedForCampagneId);
        }

        [Fact]
        public void DtoToModelShould_Map_CreationDate()
        {
            // Arrange
            var creationDate = DateTimeOffset.UtcNow;
            var dto = new NoteDocumentDto { CreationDate = creationDate };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.CreationDate, result.CreationDate);
        }

        [Fact]
        public void DtoToModelShould_Map_LastModifiedAt()
        {
            // Arrange
            var lastModifiedAt = DateTimeOffset.UtcNow;
            var dto = new NoteDocumentDto { LastModifiedAt = lastModifiedAt };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.LastModifiedAt, result.LastModifiedAt);
        }

        [Fact]
        public void DtoToModelShould_Map_Id()
        {
            // Arrange
            var id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
            var dto = new NoteDocumentDto { Id = id };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(dto.Id, result.Id);
        }

        [Fact]
        public void DtoToModelShould_Map_ImageBlocks_To_NoteBlocks()
        {
            // Arrange
            var dto = new NoteDocumentDto
            {
                ImageBlocks = new List<ImageBlock>
                {
                    new ImageBlock { PublicImageUrl = "https://example.com/image1" },
                    new ImageBlock { PublicImageUrl = "https://example.com/image2" },
                },
            };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(2, result.NoteBlocks.Count);
            Assert.IsType<ImageBlock>(result.NoteBlocks[0]);
            Assert.IsType<ImageBlock>(result.NoteBlocks[1]);
            Assert.Equal("https://example.com/image1", ((ImageBlock)result.NoteBlocks[0]).PublicImageUrl);
            Assert.Equal("https://example.com/image2", ((ImageBlock)result.NoteBlocks[1]).PublicImageUrl);
        }

        [Fact]
        public void DtoToModelShould_Map_TextBlocks_To_NoteBlocks()
        {
            // Arrange
            var dto = new NoteDocumentDto
            {
                TextBlocks = new List<TextBlock>
                {
                    new TextBlock { MarkdownText = "Text 1" },
                    new TextBlock { MarkdownText = "Text 2" },
                },
            };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(2, result.NoteBlocks.Count);
            Assert.IsType<TextBlock>(result.NoteBlocks[0]);
            Assert.IsType<TextBlock>(result.NoteBlocks[1]);
            Assert.Equal("Text 1", ((TextBlock)result.NoteBlocks[0]).MarkdownText);
            Assert.Equal("Text 2", ((TextBlock)result.NoteBlocks[1]).MarkdownText);
        }

        [Fact]
        public void DtoToModelShould_Map_Both_ImageBlocks_And_TextBlocks_To_NoteBlocks()
        {
            // Arrange
            var dto = new NoteDocumentDto
            {
                ImageBlocks = new List<ImageBlock> { new ImageBlock { PublicImageUrl = "https://example.com/image1" } },
                TextBlocks = new List<TextBlock> { new TextBlock { MarkdownText = "Sample text" } },
            };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.Equal(2, result.NoteBlocks.Count);
            Assert.IsType<ImageBlock>(result.NoteBlocks[0]);
            Assert.IsType<TextBlock>(result.NoteBlocks[1]);
            Assert.Equal("https://example.com/image1", ((ImageBlock)result.NoteBlocks[0]).PublicImageUrl);
            Assert.Equal("Sample text", ((TextBlock)result.NoteBlocks[1]).MarkdownText);
        }

        [Fact]
        public void DtoToModelShould_Handle_Empty_ImageBlocks_And_TextBlocks()
        {
            // Arrange
            var dto = new NoteDocumentDto { ImageBlocks = new List<ImageBlock>(), TextBlocks = new List<TextBlock>() };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.NotNull(result.NoteBlocks);
            Assert.Empty(result.NoteBlocks);
        }

        [Fact]
        public void DtoToModelShould_Handle_Null_ImageBlocks_And_TextBlocks()
        {
            // Arrange
            var dto = new NoteDocumentDto { ImageBlocks = null, TextBlocks = null };

            // Act
            var result = _mapper.Map<NoteDocument>(dto);

            // Assert
            Assert.NotNull(result.NoteBlocks);
            Assert.Empty(result.NoteBlocks);
        }

        [Fact]
        public void Should_Map_NoteDocument_To_NoteDocumentDto()
        {
            // Arrange
            var noteDocument = new NoteDocument
            {
                GroupName = "Test Group",
                CreatingUserId = User.UserIdentifier.From(Guid.NewGuid()),
                Title = "Test Title",
                CreatedForCampagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid()),
                NoteBlocks = new List<NoteBlockModelBase>
                {
                    new ImageBlock { PublicImageUrl = "https://example.com/image1" },
                    new TextBlock { MarkdownText = "Sample text" },
                },
            };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(noteDocument.GroupName, result.GroupName);
            Assert.Equal(noteDocument.CreatingUserId, result.CreatingUserId);
            Assert.Equal(noteDocument.Title, result.Title);
            Assert.Equal(noteDocument.CreatedForCampagneId, result.CreatedForCampagneId);

            // Check ImageBlocks
            Assert.Single(result.ImageBlocks);
            Assert.Equal("https://example.com/image1", result.ImageBlocks[0].PublicImageUrl);

            // Check TextBlocks
            Assert.Single(result.TextBlocks);
            Assert.Equal("Sample text", result.TextBlocks[0].MarkdownText);
        }

        [Fact]
        public void Should_Map_Empty_NoteBlocks_To_Empty_Lists()
        {
            // Arrange
            var noteDocument = new NoteDocument { NoteBlocks = new List<NoteBlockModelBase>() };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.NotNull(result);
            Assert.Empty(result.ImageBlocks);
            Assert.Empty(result.TextBlocks);
        }

        [Fact]
        public void Should_Handle_Null_NoteBlocks()
        {
            // Arrange
            var noteDocument = new NoteDocument { NoteBlocks = null };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.NotNull(result);
            Assert.Empty(result.ImageBlocks);
            Assert.Empty(result.TextBlocks);
        }

        [Fact]
        public void Should_Throw_Exception_For_Invalid_Configuration()
        {
            // This test ensures that the mapping configuration is valid
            var config = new MapperConfiguration(cfg =>
            {
                cfg.AddProfile<ApiDtoMapperProfile>();
            });

            config.AssertConfigurationIsValid();
        }

        [Fact]
        public void Should_Map_CreationDate()
        {
            // Arrange
            var creationDate = DateTimeOffset.UtcNow;
            var noteDocument = new NoteDocument { CreationDate = creationDate };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(creationDate, result.CreationDate);
        }

        [Fact]
        public void Should_Map_LastModifiedAt()
        {
            // Arrange
            var lastModifiedAt = DateTimeOffset.UtcNow;
            var noteDocument = new NoteDocument { LastModifiedAt = lastModifiedAt };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(lastModifiedAt, result.LastModifiedAt);
        }

        [Fact]
        public void Should_Map_Id()
        {
            // Arrange
            var id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
            var noteDocument = new NoteDocument { Id = id };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(noteDocument.Id, result.Id);
        }

        [Fact]
        public void Should_Map_GroupName()
        {
            // Arrange
            var noteDocument = new NoteDocument { GroupName = "Test Group" };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(noteDocument.GroupName, result.GroupName);
        }

        [Fact]
        public void Should_Map_CreatingUserId()
        {
            // Arrange
            var userId = User.UserIdentifier.From(Guid.NewGuid());
            var noteDocument = new NoteDocument { CreatingUserId = userId };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(noteDocument.CreatingUserId, result.CreatingUserId);
        }

        [Fact]
        public void Should_Map_Title()
        {
            // Arrange
            var noteDocument = new NoteDocument { Title = "Sample Title" };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(noteDocument.Title, result.Title);
        }

        [Fact]
        public void Should_Map_CreatedForCampagneId()
        {
            // Arrange
            var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
            var noteDocument = new NoteDocument { CreatedForCampagneId = campagneId };

            // Act
            var result = _mapper.Map<NoteDocumentDto>(noteDocument);

            // Assert
            Assert.Equal(noteDocument.CreatedForCampagneId, result.CreatedForCampagneId);
        }
    }
}
