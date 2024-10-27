using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users;

public class UserExistsByInternalIdQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsUserId()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory,
            Mapper,
            cancellationToken: default,
            signInProviderId: "qwer"
        );

        var query = new UserExistsByInternalIdQuery
        {
            SignInProviderId = user.SignInProviderId.Get(),
        };
        var subjectUnderTest = new UserExistsByInternalIdQueryHandler(ContextFactory);

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

        var query = new UserExistsByInternalIdQuery { SignInProviderId = "asdf" };
        var subjectUnderTest = new UserExistsByInternalIdQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsNone.Should().BeTrue("because the retrieval should found nothing");
    }
}
