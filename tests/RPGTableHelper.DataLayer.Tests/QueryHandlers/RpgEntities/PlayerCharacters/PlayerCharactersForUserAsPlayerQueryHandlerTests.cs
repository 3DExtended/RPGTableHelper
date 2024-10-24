using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.PlayerCharacters;

public class PlayerCharactersForUserAsPlayerQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var user1 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);
        var user2 = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            usernameOverride: "Username2"
        );

        var entity1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla1",
            PlayerUserId = user1.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };
        var entity2 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla2",
            PlayerUserId = user2.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };
        var entity3 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CharacterName = "Bla3",
            PlayerUserId = user1.Id.Value,
            RpgCharacterConfiguration = "hjkljhghjkl",
        };

        Context.PlayerCharacters.Add(entity1);
        Context.PlayerCharacters.Add(entity2);
        Context.PlayerCharacters.Add(entity3);
        Context.SaveChanges();

        var query = new PlayerCharactersForUserAsPlayerQuery { UserId = user1.Id };
        var subjectUnderTest = new PlayerCharactersForUserAsPlayerQueryHandler(
            Mapper,
            ContextFactory
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Count.Should().Be(2);
        result.Get().Select(c => c.CharacterName).Should().Contain("Bla1");
        result.Get().Select(c => c.CharacterName).Should().Contain("Bla3");
    }
}
