using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.OpenSignInProviderRegisterRequests;

public class OpenSignInProviderRegisterRequestCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var model = new OpenSignInProviderRegisterRequest
        {
            Id = OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier.From(
                Guid.Empty
            ),
            Email = "ala@asdf.de",
            ExposedApiKey = "dfghjklkjhgfd",
            IdentityProviderId = "asdfasdfasdf",
            SignInProviderRefreshToken = "ghnkiuzhgbnmjiuh",
            SignInProviderUsed = SupportedSignInProviders.Apple,
        };
        var query = new OpenSignInProviderRegisterRequestCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new OpenSignInProviderRegisterRequestCreateQueryHandler(
            Mapper,
            ContextFactory,
            SystemClock
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.OpenSignInProviderRegisterRequests.ToList();
        entities.Should().HaveCount(1);
        entities[0].Email.Should().Be(model.Email);
        entities[0].ExposedApiKey.Should().Be(model.ExposedApiKey);
        entities[0].IdentityProviderId.Should().Be(model.IdentityProviderId);
        entities[0].SignInProviderRefreshToken.Should().Be(model.SignInProviderRefreshToken.Get());
        entities[0].SignInProviderUsed.Should().Be(model.SignInProviderUsed);

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
