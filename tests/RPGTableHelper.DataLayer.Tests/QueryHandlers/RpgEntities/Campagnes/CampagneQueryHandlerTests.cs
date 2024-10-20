using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.Campagnes;

public class CampagneQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla1",
            DmUserId = user.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };
        var entity2 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla2",
            DmUserId = user.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };
        var entity3 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla3",
            DmUserId = user.Id.Value,
            RpgConfiguration = "hjkljhghjkl",
        };

        Context.Campagnes.Add(entity1);
        Context.Campagnes.Add(entity2);
        Context.Campagnes.Add(entity3);
        Context.SaveChanges();

        var query = new CampagneQuery { ModelId = Campagne.CampagneIdentifier.From(entity2.Id) };
        var subjectUnderTest = new CampagneQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Id.Should().Be(Campagne.CampagneIdentifier.From(entity2.Id));
        result.Get().CampagneName.Should().Be("Bla2");
        result.Get().RpgConfiguration.Should().Be("hjkljhghjkl");
        result.Get().DmUserId.Value.Should().Be(user.Id.Value);
    }
}
