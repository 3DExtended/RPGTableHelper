using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.Campagnes;

public class CampagnesForUserAsDmQueryHandlerTests : QueryHandlersTestBase
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

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla1",
            DmUserId = user1.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };
        var entity2 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla2",
            DmUserId = user2.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };
        var entity3 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla3",
            DmUserId = user1.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };

        Context.Campagnes.Add(entity1);
        Context.Campagnes.Add(entity2);
        Context.Campagnes.Add(entity3);
        Context.SaveChanges();

        var query = new CampagnesForUserAsDmQuery { UserId = user1.Id };
        var subjectUnderTest = new CampagnesForUserAsDmQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Count.Should().Be(2);
        result.Get().Select(c => c.CampagneName).Should().Contain("Bla1");
        result.Get().Select(c => c.CampagneName).Should().Contain("Bla3");
    }
}
