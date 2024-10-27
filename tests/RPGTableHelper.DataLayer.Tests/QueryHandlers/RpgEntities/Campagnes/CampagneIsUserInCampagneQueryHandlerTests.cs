using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.Campagnes;

public class CampagneIsUserInCampagneQueryHandlerTests : QueryHandlersTestBase
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

        var player1 = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            usernameOverride: "Player1"
        );
        var player2 = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            usernameOverride: "Player2"
        );
        var player3 = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            usernameOverride: "Player3"
        );

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla1",
            DmUserId = user1.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
            JoinCode = "123-124",
        };
        var entity2 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla2",
            DmUserId = user2.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
            JoinCode = "123-125",
        };
        var entity3 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla3",
            DmUserId = user1.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
            JoinCode = "123-126",
        };

        Context.Campagnes.Add(entity1);
        Context.Campagnes.Add(entity2);
        Context.Campagnes.Add(entity3);
        Context.SaveChanges();

        var playerChar1 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = entity1.Id,
            CharacterName = "Char1",
            PlayerUserId = player1.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };
        var playerChar2 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = entity1.Id,
            CharacterName = "Char2",
            PlayerUserId = player2.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };
        var playerChar3 = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = entity2.Id,
            CharacterName = "Char3",
            PlayerUserId = player3.Id.Value,
            RpgCharacterConfiguration = "asdf",
        };
        Context.PlayerCharacters.Add(playerChar1);
        Context.PlayerCharacters.Add(playerChar2);
        Context.PlayerCharacters.Add(playerChar3);
        Context.SaveChanges();

        var query = new CampagneIsUserInCampagneQuery
        {
            UserIdToCheck = player2.Id,
            CampagneId = Campagne.CampagneIdentifier.From(entity1.Id),
        };
        var subjectUnderTest = new CampagneIsUserInCampagneQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Should().BeTrue();
    }
}
