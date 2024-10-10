using FluentAssertions;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public class UserCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var model = new User { Id = User.UserIdentifier.From(Guid.Empty), Username = "Bla" };
        var query = new UserCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new UserCreateQueryHandler(Mapper, ContextFactory, SystemClock);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.Users.ToList();
        entities.Should().HaveCount(1);
        entities[0].Username.Should().Be("Bla");

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
