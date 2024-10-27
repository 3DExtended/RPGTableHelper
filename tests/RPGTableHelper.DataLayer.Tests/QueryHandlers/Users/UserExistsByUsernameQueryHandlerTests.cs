using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users;

public class UserExistsByUsernameQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsUserId()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            cancellationToken: default
        );

        var query = new UserExistsByUsernameQuery { Username = user.Username };
        var subjectUnderTest = new UserExistsByUsernameQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Value.Should().Be(user.Id.Value);
    }

    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsNoneIfNoCorrectUserFound()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            cancellationToken: default
        );

        var query = new UserExistsByUsernameQuery { Username = "asdf" };
        var subjectUnderTest = new UserExistsByUsernameQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsNone.Should().BeTrue("because the retrieval should found nothing");
    }
}
