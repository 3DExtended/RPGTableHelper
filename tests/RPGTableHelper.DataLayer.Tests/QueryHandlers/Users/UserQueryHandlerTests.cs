using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users;

public class SingleModelQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesEntityCorrectly()
    {
        // Arrange
        var entity1 = new UserEntity
        {
            Id = Guid.Empty,
            Username = "Bla1",
            SignInProviderId = "bhzujkmn1",
        };
        var entity2 = new UserEntity
        {
            Id = Guid.Empty,
            Username = "Bla2",
            SignInProviderId = "bhzujkmn2",
        };
        var entity3 = new UserEntity
        {
            Id = Guid.Empty,
            Username = "Bla3",
            SignInProviderId = "bhzujkmn3",
        };

        Context.Users.Add(entity1);
        Context.Users.Add(entity2);
        Context.Users.Add(entity3);
        Context.SaveChanges();

        var query = new UserQuery { ModelId = User.UserIdentifier.From(entity2.Id) };
        var subjectUnderTest = new UserQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Id.Should().Be(User.UserIdentifier.From(entity2.Id));
        result.Get().Username.Should().Be("Bla2");
        result.Get().SignInProviderId.Should().Be("bhzujkmn2");
    }
}
