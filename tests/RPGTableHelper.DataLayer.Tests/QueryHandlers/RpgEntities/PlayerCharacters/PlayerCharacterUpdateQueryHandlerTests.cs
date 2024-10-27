using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.PlayerCharacters;

public class PlayerCharacterUpdateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_UpdatesEntityCorrectly()
    {
        // Arrange
        var user1 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla1",
            PlayerUserId = user1.Id.Value,
            RpgCharacterConfiguration = null,
        };
        var entity2 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla2",
            PlayerUserId = user1.Id.Value,
            RpgCharacterConfiguration = null,
        };
        var entity3 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla3",
            PlayerUserId = user1.Id.Value,
            RpgCharacterConfiguration = null,
        };

        Context.PlayerCharacters.Add(entity1);
        Context.PlayerCharacters.Add(entity2);
        Context.PlayerCharacters.Add(entity3);
        Context.SaveChanges();

        var query = new PlayerCharacterUpdateQuery
        {
            UpdatedModel = new()
            {
                Id = PlayerCharacter.PlayerCharacterIdentifier.From(entity2.Id),
                CharacterName = "Foo",
                PlayerUserId = user1.Id,
                RpgCharacterConfiguration = "ghjkjhgfhjkjhg",
            },
        };
        var subjectUnderTest = new PlayerCharacterUpdateQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the update should be successful");
        var entityCount = Context.PlayerCharacters.Count();
        entityCount.Should().Be(3);

        var updatedEntity = Context.PlayerCharacters.AsNoTracking().First(x => x.Id == entity2.Id);
        updatedEntity!.CharacterName.Should().Be("Foo");
        updatedEntity!.RpgCharacterConfiguration.Should().Be("ghjkjhgfhjkjhg");
    }
}
