using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users;

public class UsersQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_RetrievesAllUsersCorrectly()
    {
        // Arrange
        var entity1 = new UserEntity { Id = Guid.Empty, Username = "Bla1" };
        var entity2 = new UserEntity { Id = Guid.Empty, Username = "Bla2" };
        var entity3 = new UserEntity { Id = Guid.Empty, Username = "Bla3" };

        Context.Users.Add(entity1);
        Context.Users.Add(entity2);
        Context.Users.Add(entity3);
        Context.SaveChanges();

        var query = new UsersQuery { Ids = Option.None };
        var subjectUnderTest = new UsersQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Should().HaveCount(3);
    }

    [Fact]
    public async Task RunQueryAsync_RetrievesSelectedUsersCorrectly()
    {
        // Arrange
        var entity1 = new UserEntity { Id = Guid.Empty, Username = "Bla1" };
        var entity2 = new UserEntity { Id = Guid.Empty, Username = "Bla2" };
        var entity3 = new UserEntity { Id = Guid.Empty, Username = "Bla3" };

        Context.Users.Add(entity1);
        Context.Users.Add(entity2);
        Context.Users.Add(entity3);
        Context.SaveChanges();

        var query = new UsersQuery
        {
            Ids = new List<User.UserIdentifier>
            {
                User.UserIdentifier.From(entity2.Id),
                User.UserIdentifier.From(entity3.Id),
            },
        };
        var subjectUnderTest = new UsersQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Should().HaveCount(2);

        var orderedList = result.Get().OrderBy(x => x.Username).ToList();

        orderedList.First().Id.Should().Be(User.UserIdentifier.From(entity2.Id));
        orderedList.First().Username.Should().Be("Bla2");

        orderedList.Last().Id.Should().Be(User.UserIdentifier.From(entity3.Id));
        orderedList.Last().Username.Should().Be("Bla3");
    }
}
