using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public class UserDeleteQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_DeletesModelSuccessfully()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var query = new UserDeleteQuery { Id = user.Id };
        var subjectUnderTest = new UserDeleteQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the deletion should be successful");

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var entities = await context.UserCredentials.ToListAsync(default);
            entities.Should().HaveCount(0);
        }
    }
}
