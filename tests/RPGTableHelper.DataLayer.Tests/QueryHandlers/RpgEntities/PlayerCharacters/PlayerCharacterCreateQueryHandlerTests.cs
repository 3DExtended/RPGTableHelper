using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.PlayerCharacters;

public class PlayerCharacterCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var model = new PlayerCharacter
        {
            Id = PlayerCharacter.PlayerCharacterIdentifier.From(Guid.Empty),
            CharacterName = "Bla",
            PlayerUserId = user.Id,
            RpgCharacterConfiguration = Option.None,
        };
        var query = new PlayerCharacterCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new PlayerCharacterCreateQueryHandler(
            Mapper,
            ContextFactory,
            SystemClock
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.PlayerCharacters.ToList();
        entities.Should().HaveCount(1);
        entities[0].CharacterName.Should().Be("Bla");
        entities[0].PlayerUserId.Should().Be(user.Id.Value);
        entities[0].RpgCharacterConfiguration.Should().BeNull();

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
