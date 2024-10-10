using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Encryptions;

public class EncryptionChallengeForUserQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_FindsEncryptionChallengeForUsername()
    {
        // Arrange
        var (user, encryptionChallenge) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeInDb(ContextFactory, Mapper);

        var query = new EncryptionChallengeForUserQuery { Username = user.Username };
        var subjectUnderTest = new EncryptionChallengeForUserQueryHandler(Mapper, ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the search should be successful");
        result.Get().Id.Value.Should().Be(encryptionChallenge.Id.Value);
        result.Get().RndInt.Should().Be(encryptionChallenge.RndInt);
        result.Get().PasswordPrefix.Should().Be(encryptionChallenge.PasswordPrefix);
        result.Get().UserId.Value.Should().Be(user.Id.Value);
    }
}
