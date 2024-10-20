using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.PlayerCharacters;

public class PlayerCharacterQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla1",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };
        var entity2 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla2",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };
        var entity3 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla3",
            PlayerUserId = user.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };

        Context.PlayerCharacters.Add(entity1);
        Context.PlayerCharacters.Add(entity2);
        Context.PlayerCharacters.Add(entity3);
        Context.SaveChanges();

        var query = new PlayerCharacterQuery
        {
            ModelId = PlayerCharacter.PlayerCharacterIdentifier.From(entity2.Id),
        };
        var subjectUnderTest = new PlayerCharacterQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Id.Should().Be(PlayerCharacter.PlayerCharacterIdentifier.From(entity2.Id));
        result.Get().CharacterName.Should().Be("Bla2");
        result.Get().RpgCharacterConfiguration.Should().Be("hjkljhghjkl");
        result.Get().PlayerUserId.Value.Should().Be(user.Id.Value);
    }
}
