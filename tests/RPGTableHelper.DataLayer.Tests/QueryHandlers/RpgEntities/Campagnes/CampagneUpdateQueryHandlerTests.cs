using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.RpgEntities.Campagnes;

public class CampagneUpdateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_UpdatesEntityCorrectly()
    {
        // Arrange
        var user1 = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var entity1 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla1",
            DmUserId = user1.Id.Value,
            RpgConfiguration = null,
            JoinCode = "123-123",
        };
        var entity2 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla2",
            DmUserId = user1.Id.Value,
            RpgConfiguration = null,
            JoinCode = "123-124",
        };
        var entity3 = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "Bla3",
            DmUserId = user1.Id.Value,
            RpgConfiguration = null,
            JoinCode = "123-125",
        };

        Context.Campagnes.Add(entity1);
        Context.Campagnes.Add(entity2);
        Context.Campagnes.Add(entity3);
        Context.SaveChanges();

        var query = new CampagneUpdateQuery
        {
            UpdatedModel = new()
            {
                Id = Campagne.CampagneIdentifier.From(entity2.Id),
                CampagneName = "Foo",
                DmUserId = user1.Id,
                RpgConfiguration = "ghjkjhgfhjkjhg",
                JoinCode = "321-321",
            },
        };
        var subjectUnderTest = new CampagneUpdateQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the update should be successful");
        var entityCount = Context.Campagnes.Count();
        entityCount.Should().Be(3);

        var updatedEntity = Context.Campagnes.AsNoTracking().First(x => x.Id == entity2.Id);
        updatedEntity!.CampagneName.Should().Be("Foo");
        updatedEntity!.JoinCode.Should().Be("321-321");
        updatedEntity!.RpgConfiguration.Should().Be("ghjkjhgfhjkjhg");
    }
}
