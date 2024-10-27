using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.OpenSignInProviderRegisterRequests;

public class OpenSignInProviderRegisterRequestExistsByApiKeyQueryHandlerTests
    : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsRequest()
    {
        // Arrange
        var request = await RpgDbContextHelpers.CreateOpenSignInProviderRegisterRequestInDb(
            ContextFactory,
            Mapper,
            cancellationToken: default
        );

        var query = new OpenSignInProviderRegisterRequestExistsByApiKeyQuery
        {
            ApiKey = request.ExposedApiKey,
        };

        var subjectUnderTest = new OpenSignInProviderRegisterRequestExistsByApiKeyQueryHandler(
            ContextFactory,
            Mapper
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the retrieval should be successful");
        result.Get().Id.Value.Should().Be(request.Id.Value);
        result.Get().Email.Should().Be(request.Email);
        result.Get().ExposedApiKey.Should().Be(request.ExposedApiKey);
        result.Get().SignInProviderUsed.Should().Be(request.SignInProviderUsed);
        result.Get().SignInProviderRefreshToken.Should().Be(request.SignInProviderRefreshToken);
        result.Get().IdentityProviderId.Should().Be(request.IdentityProviderId);
    }

    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsNoneIfNoCorrectRequestFound()
    {
        // Arrange
        var request = await RpgDbContextHelpers.CreateOpenSignInProviderRegisterRequestInDb(
            ContextFactory,
            Mapper,
            cancellationToken: default
        );

        var query = new OpenSignInProviderRegisterRequestExistsByApiKeyQuery { ApiKey = "asdf" };
        var subjectUnderTest = new OpenSignInProviderRegisterRequestExistsByApiKeyQueryHandler(
            ContextFactory,
            Mapper
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsNone.Should().BeTrue("because the retrieval should found nothing");
    }
}
