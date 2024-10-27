using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Users;

public class UserLoginQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsUserId()
    {
        // Arrange
        var (user, encryChallenge, creds) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                cancellationToken: default
            );

        var query = new UserLoginQuery
        {
            Username = user.Username,
            HashedPassword = creds.HashedPassword.Get(),
        };
        var subjectUnderTest = new UserLoginQueryHandler(ContextFactory);

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
        var (user, encryChallenge, creds) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                cancellationToken: default
            );

        var query = new UserLoginQuery
        {
            Username = "asdf",
            HashedPassword = creds.HashedPassword.Get(),
        };

        var subjectUnderTest = new UserLoginQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result
            .IsNone.Should()
            .BeTrue("because the retrieval should found nothing since username does not exist");
    }

    [Fact]
    public async Task RunQueryAsync_CorrectlyReturnsNoneIfPasswordDoesNotMatch()
    {
        // Arrange
        var (user, encryChallenge, creds) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                cancellationToken: default
            );

        var query = new UserLoginQuery
        {
            Username = user.Username,
            HashedPassword = "bnm,kjuhzgtfrzuj",
        };

        var subjectUnderTest = new UserLoginQueryHandler(ContextFactory);

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result
            .IsNone.Should()
            .BeTrue("because the retrieval should found nothing since password was wrong");
    }
}
