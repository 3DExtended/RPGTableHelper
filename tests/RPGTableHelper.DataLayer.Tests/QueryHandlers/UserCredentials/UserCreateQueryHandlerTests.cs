using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers;
using RPGTableHelper.DataLayer.QueryHandlers.UserCredentials;
using RPGTableHelper.DataLayer.QueryHandlers.Users;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public class UserCredentialCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var (user, challenge) = await RpgDbContextHelpers.CreateUserWithEncryptionChallengeInDb(
            ContextFactory,
            Mapper,
            default
        );

        var model = new UserCredential
        {
            Id = UserCredential.UserCredentialIdentifier.From(Guid.Empty),
            Deleted = false,
            Email = "asdf@asdf.de",
            EmailVerified = Option.None,
            EncryptionChallengeId = challenge.Id,
            HashedPassword = "dfghjkoiuzhgj",
            PasswordResetToken = Option.None,
            PasswordResetTokenExpireDate = SystemClock.Now,
            RefreshToken = Option.None,
            SignInProvider = true,
            UserId = user.Id,
        };

        var query = new UserCredentialCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new UserCredentialCreateQueryHandler(
            Mapper,
            ContextFactory,
            SystemClock
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.UserCredentials.ToList();
        entities.Should().HaveCount(1);

        entities[0].Id.Should().NotBe(Guid.Empty);
        entities[0].Deleted.Should().Be(false);

        entities[0].Email.Should().Be("asdf@asdf.de");
        entities[0].EmailVerified.Should().BeNull();
        entities[0].EncryptionChallengeId.Should().Be(challenge.Id.Value);
        entities[0].HashedPassword.Should().Be("dfghjkoiuzhgj");
        entities[0].PasswordResetToken.Should().BeNull();
        entities[0].PasswordResetTokenExpireDate.Should().Be(SystemClock.Now);
        entities[0].RefreshToken.Should().BeNull();
        entities[0].SignInProvider.Should().Be(true);
        entities[0].UserId.Should().Be(user.Id.Value);

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
