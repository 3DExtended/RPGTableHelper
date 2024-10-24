using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.Campagnes;

public class CampagneCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var model = new Campagne
        {
            Id = Campagne.CampagneIdentifier.From(Guid.Empty),
            CampagneName = "Bla",
            DmUserId = user.Id,
            RpgConfiguration = Option.None,
            JoinCode = "123-123",
        };
        var query = new CampagneCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new CampagneCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.Campagnes.ToList();
        entities.Should().HaveCount(1);
        entities[0].CampagneName.Should().Be("Bla");
        entities[0].DmUserId.Should().Be(user.Id.Value);
        entities[0].RpgConfiguration.Should().BeNull();

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
