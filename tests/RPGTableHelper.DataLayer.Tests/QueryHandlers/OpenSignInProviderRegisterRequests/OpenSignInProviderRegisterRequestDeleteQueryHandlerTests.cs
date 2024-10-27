using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.OpenSignInProviderRegisterRequests;

public class OpenSignInProviderRegisterRequestDeleteQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_DeletesModelSuccessfully()
    {
        // Arrange
        var openSignInProviderRegisterRequest =
            await RpgDbContextHelpers.CreateOpenSignInProviderRegisterRequestInDb(
                ContextFactory,
                Mapper
            );

        var query = new OpenSignInProviderRegisterRequestDeleteQuery
        {
            Id = openSignInProviderRegisterRequest.Id,
        };
        var subjectUnderTest = new OpenSignInProviderRegisterRequestDeleteQueryHandler(
            ContextFactory
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the deletion should be successful");

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var entities = await context.OpenSignInProviderRegisterRequests.ToListAsync(default);
            entities.Should().HaveCount(0);
        }
    }
}
