using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Encryptions;

public class UserCredentialConfirmEmailQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CorrectlyConfirmsUserEmail()
    {
        // Arrange
        var (user, encryptionChallenge, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper
            );

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var entities = await context.UserCredentials.ToListAsync(default);
            entities.Should().HaveCount(1);
            entities[0].EmailVerified.Should().BeFalse();
        }

        var query = new UserCredentialConfirmEmailQuery { UserIdentifier = user.Id };
        var subjectUnderTest = new UserCredentialConfirmEmailQueryHandler(
            ContextFactory,
            SystemClock
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the confirmation should be successful");

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var asdf = await context.UserCredentials.ToListAsync(default);
            asdf.Should().HaveCount(1);
            asdf[0].EmailVerified.Should().BeTrue();
        }
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidUserId()
    {
        // Arrange
        var query = new UserCredentialConfirmEmailQuery
        {
            UserIdentifier = User.UserIdentifier.From(Guid.NewGuid()),
        };
        var subjectUnderTest = new UserCredentialConfirmEmailQueryHandler(
            ContextFactory,
            SystemClock
        );

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var entities = await context.UserCredentials.ToListAsync(default);
            entities.Should().HaveCount(0);
        }

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the user does not exist");
    }
}
