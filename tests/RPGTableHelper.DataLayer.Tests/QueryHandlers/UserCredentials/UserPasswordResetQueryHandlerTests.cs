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

public class UserPasswordResetQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_SuccessfullyResetsPassword()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        // Mock RSA decryption query
        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the password reset should be successful");

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var credential = await context.UserCredentials.FirstAsync();
            credential.HashedPassword.Should().Be("new-password");
            credential.PasswordResetToken.Should().BeNull();
            credential.PasswordResetTokenExpireDate.Should().BeNull();
        }
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidUsername()
    {
        // Arrange
        var query = new UserPasswordResetQuery
        {
            Username = "invalid-username",
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        var subjectUnderTest = new UserPasswordResetQueryHandler(
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
    public async Task RunQueryAsync_ShouldFailForExpiredToken()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "expired-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(-1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "expired-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the reset token is expired");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidEmail()
    {
        // Arrange

        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "wrong-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the email does not match the decrypted email");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForInvalidResetCode()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "invalid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the reset code is invalid");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForNullEmailAddress()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: null, // No email set up
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the email address is not set up in the database");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForNullPasswordResetToken()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: null, // No password reset token
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the password reset token is null in the database");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForNullPasswordResetTokenExpireDate()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: null // No expiration date
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeFalse("because the password reset token expiration date is null");
    }

    [Fact]
    public async Task RunQueryAsync_ShouldFailForMismatchedDecryptedEmail()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "wrong-decrypted-email", // Incorrect email
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
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
    public async Task RunQueryAsync_ShouldSendEmailAfterPasswordReset()
    {
        // Arrange
        var (user, _, userCredential) =
            await RpgDbContextHelpers.CreateUserWithEncryptionChallengeAndCredentialsInDb(
                ContextFactory,
                Mapper,
                email: "encrypted-email",
                passwordResetToken: "valid-token",
                passwordResetTokenExpireDate: SystemClock.Now.AddHours(1)
            );

        var query = new UserPasswordResetQuery
        {
            Username = user.Username,
            Email = "decrypted-email",
            ResetCode = "valid-token",
            NewHashedPassword = "new-password",
        };

        var queryProcessor = Substitute.For<IQueryProcessor>();
        queryProcessor
            .RunQueryAsync<RSADecryptStringQuery, string>(
                Arg.Any<RSADecryptStringQuery>(),
                Arg.Any<CancellationToken>()
            )
            .Returns("decrypted-email");

        var subjectUnderTest = new UserPasswordResetQueryHandler(
            ContextFactory,
            SystemClock,
            queryProcessor
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the password reset should be successful");

        await queryProcessor
            .Received(1)
            .RunQueryAsync<EmailSendQuery, Unit>(
                Arg.Any<EmailSendQuery>(),
                Arg.Any<CancellationToken>()
            );

        using (var context = await ContextFactory.CreateDbContextAsync(default))
        {
            var credential = await context.UserCredentials.FirstAsync();
            credential.HashedPassword.Should().Be("new-password");
        }
    }
}
