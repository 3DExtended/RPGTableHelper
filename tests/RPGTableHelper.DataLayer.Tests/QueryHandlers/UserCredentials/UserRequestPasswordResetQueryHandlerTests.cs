using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using NSubstitute;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges;
using RPGTableHelper.DataLayer.QueryHandlers.UserCredentials;
using RPGTableHelper.DataLayer.SendGrid.Contracts.Queries;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.UserCredentials;

public class UserRequestPasswordResetQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_ShouldSucceedForValidRequest()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email"
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        queryProcessor
            .RunQueryAsync<EmailSendQuery, Unit>(
                Arg.Any<EmailSendQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns(Unit.Value); // Simulate email send failure

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the request is valid and should succeed");

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var credential = await context.UserCredentials.FirstAsync();
            credential.PasswordResetToken.Should().NotBeNull();
            credential.PasswordResetTokenExpireDate.Should().BeAfter(SystemClock.Now);
        }

        await queryProcessor
            .Received(1)
            .RunQueryAsync<EmailSendQuery, Unit>(
                Arg.Any<EmailSendQuery>(),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidUsername()
    {
        // Arrange
        var query = new UserRequestPasswordResetQuery
        {
            Username = "invalid-username",
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the username does not exist");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidEmail()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email"
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "incorrect-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result
            .IsSome.Should()
            .BeFalse("because the decrypted email does not match the provided email");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForNullEmail()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: null // Null email
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the user's email is null in the database");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailIfResetTokenAlreadyExists()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "existing-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1) // Token still valid
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because a reset token already exists and hasn't expired");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForSignInProviderFlag()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                signInProvider: true // User registered with an external sign-in provider
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result
            .IsSome.Should()
            .BeFalse("because the user is registered with an external sign-in provider");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailIfEmailSendFails()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email"
            );

        var query = new UserRequestPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        queryProcessor
            .RunQueryAsync<EmailSendQuery, Unit>(
                Arg.Any<EmailSendQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns(Option.None); // Simulate email send failure

        var subjectUnderTest = new UserRequestPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the email send process failed");
    }
}
