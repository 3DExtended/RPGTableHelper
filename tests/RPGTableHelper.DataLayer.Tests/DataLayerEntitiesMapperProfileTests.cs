namespace RPGTableHelper.DataLayer.Tests;

using AutoMapper;
using FluentAssertions;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

public class DataLayerEntitiesMapperProfileTests
{
    private readonly IMapper _mapper;

    public DataLayerEntitiesMapperProfileTests()
    {
        var config = new MapperConfiguration(cfg =>
        {
            cfg.AddProfile<DataLayerEntitiesMapperProfile>();
            cfg.AddProfile<SharedMapperProfile>();
        });

        _mapper = config.CreateMapper();
    }

    [Fact]
    public void UserToUserEntity_ShouldMapSuccessfully()
    {
        // Arrange
        var user = new User
        {
            Username = "TestUser",
            Id = User.UserIdentifier.From(Guid.NewGuid()),
        };

        // Act
        var userEntity = _mapper.Map<UserEntity>(user);

        // Assert
        userEntity.Should().NotBeNull();
        userEntity.Username.Should().Be(user.Username);
        userEntity.Id.Should().Be(user.Id.Value);
    }

    [Fact]
    public void UserEntityToUser_ShouldMapSuccessfully()
    {
        // Arrange
        var userEntity = new UserEntity
        {
            Username = "TestUserEntity",
            Id = Guid.NewGuid(),
            CreationDate = DateTimeOffset.UtcNow,
            LastModifiedAt = DateTimeOffset.UtcNow,
        };

        // Act
        var user = _mapper.Map<User>(userEntity);

        // Assert
        user.Should().NotBeNull();
        user.Username.Should().Be(userEntity.Username);
        user.Id.Value.Should().Be(userEntity.Id);
        user.CreationDate.Should().Be(userEntity.CreationDate);
        user.LastModifiedAt.Should().Be(userEntity.LastModifiedAt);
    }

    [Fact]
    public void EncryptionChallengeToEncryptionChallengeEntity_ShouldMapSuccessfully()
    {
        // Arrange
        var encryptionChallenge = new EncryptionChallenge
        {
            PasswordPrefix = "TestEncryptionChallenge",
            RndInt = 34567,
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 2, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2023, 10, 10, 10, 10, 2, TimeSpan.Zero),
            Id = EncryptionChallenge.EncryptionChallengeIdentifier.From(Guid.NewGuid()),
        };

        // Act
        var encryptionChallengeEntity = _mapper.Map<EncryptionChallengeEntity>(encryptionChallenge);

        // Assert
        encryptionChallengeEntity.Should().NotBeNull();
        encryptionChallengeEntity.PasswordPrefix.Should().Be(encryptionChallenge.PasswordPrefix);
        encryptionChallengeEntity.RndInt.Should().Be(encryptionChallenge.RndInt);
        encryptionChallengeEntity.Id.Should().Be(encryptionChallenge.Id.Value);
        encryptionChallengeEntity.CreationDate.Should().Be(encryptionChallenge.CreationDate);
        encryptionChallengeEntity.LastModifiedAt.Should().Be(encryptionChallenge.LastModifiedAt);
    }

    [Fact]
    public void EncryptionChallengeEntityToEncryptionChallenge_ShouldMapSuccessfully()
    {
        // Arrange
        var encryptionChallengeEntity = new EncryptionChallengeEntity
        {
            PasswordPrefix = "TestEncryptionChallengeEntity",
            RndInt = 254321,
            Id = Guid.NewGuid(),
            CreationDate = DateTimeOffset.UtcNow,
            LastModifiedAt = DateTimeOffset.UtcNow,
        };

        // Act
        var encryptionChallenge = _mapper.Map<EncryptionChallenge>(encryptionChallengeEntity);

        // Assert
        encryptionChallenge.Should().NotBeNull();
        encryptionChallenge.PasswordPrefix.Should().Be(encryptionChallengeEntity.PasswordPrefix);
        encryptionChallenge.RndInt.Should().Be(encryptionChallengeEntity.RndInt);
        encryptionChallenge.Id.Value.Should().Be(encryptionChallengeEntity.Id);
        encryptionChallenge.CreationDate.Should().Be(encryptionChallengeEntity.CreationDate);
        encryptionChallenge.LastModifiedAt.Should().Be(encryptionChallengeEntity.LastModifiedAt);
    }

    [Fact]
    public void UserCredentialToUserCredentialEntity_ShouldMapSuccessfully()
    {
        // Arrange
        var userCredential = new UserCredential
        {
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 2, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2023, 10, 10, 10, 10, 2, TimeSpan.Zero),
            Id = UserCredential.UserCredentialIdentifier.From(Guid.NewGuid()),
            Deleted = true,
            Email = "asdf@asdf.de",
            EmailVerified = Option.None,
            EncryptionChallengeId = EncryptionChallenge.EncryptionChallengeIdentifier.From(
                Guid.NewGuid()
            ),
            HashedPassword = Option.None,
            PasswordResetToken = "asdfewflkjwefökj",
            PasswordResetTokenExpireDate = new DateTimeOffset(
                2024,
                10,
                10,
                10,
                10,
                10,
                TimeSpan.Zero
            ),
            RefreshToken = "ghjkl",
            SignInProvider = false,
            UserId = User.UserIdentifier.From(Guid.NewGuid()),
        };

        // Act
        var userCredentialEntity = _mapper.Map<UserCredentialEntity>(userCredential);

        // Assert
        userCredentialEntity.Should().NotBeNull();
        userCredentialEntity.Id.Should().Be(userCredential.Id.Value);
        userCredentialEntity.CreationDate.Should().Be(userCredential.CreationDate);
        userCredentialEntity.LastModifiedAt.Should().Be(userCredential.LastModifiedAt);

        userCredentialEntity.Deleted.Should().Be(userCredential.Deleted);
        userCredentialEntity.Email!.Should().Be(userCredential.Email.Get());
        userCredentialEntity.EmailVerified.Should().BeNull();
        userCredentialEntity.EncryptionChallengeId.HasValue.Should().BeTrue();
        userCredentialEntity
            .EncryptionChallengeId.Value.Should()
            .Be(userCredential.EncryptionChallengeId.Get().Value);
        userCredentialEntity.HashedPassword.Should().BeNull();
        userCredentialEntity
            .PasswordResetToken.Should()
            .Be(userCredential.PasswordResetToken.Get());
        userCredentialEntity
            .PasswordResetTokenExpireDate.Should()
            .Be(userCredential.PasswordResetTokenExpireDate.Get());
        userCredentialEntity.RefreshToken.Should().Be(userCredential.RefreshToken.Get());
        userCredentialEntity.SignInProvider.Should().Be(userCredential.SignInProvider);
        userCredentialEntity.UserId.Should().Be(userCredential.UserId.Value);

        userCredentialEntity.User.Should().BeNull();
        userCredentialEntity.EncryptionChallengeOfUser.Should().BeNull();
    }

    [Fact]
    public void UserCredentialEntityToUserCredential_ShouldMapSuccessfully()
    {
        // Arrange
        var userCredentialEntity = new UserCredentialEntity
        {
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 2, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2023, 10, 10, 10, 10, 2, TimeSpan.Zero),
            Id = Guid.NewGuid(),
            Deleted = true,
            Email = "asdf@asdf.de",
            EmailVerified = null,
            EncryptionChallengeId = Guid.NewGuid(),
            HashedPassword = null,
            PasswordResetToken = "asdfewflkjwefökj",
            PasswordResetTokenExpireDate = new DateTimeOffset(
                2024,
                10,
                10,
                10,
                10,
                10,
                TimeSpan.Zero
            ),
            RefreshToken = "ghjkl",
            SignInProvider = false,
            UserId = Guid.NewGuid(),
        };

        // Act
        var userCredential = _mapper.Map<UserCredential>(userCredentialEntity);

        // Assert
        userCredential.Should().NotBeNull();
        userCredential.Id.Value.Should().Be(userCredentialEntity.Id);
        userCredential.CreationDate.Should().Be(userCredentialEntity.CreationDate);
        userCredential.LastModifiedAt.Should().Be(userCredentialEntity.LastModifiedAt);

        userCredential.Deleted.Should().Be(userCredentialEntity.Deleted);

        userCredential.Email.Should().Be(userCredentialEntity.Email.ToOption());
        userCredential.EmailVerified.IsNone.Should().BeTrue();

        userCredential.EncryptionChallengeId.IsSome.Should().BeTrue();
        userCredential
            .EncryptionChallengeId.Get()
            .Value.Should()
            .Be(userCredentialEntity.EncryptionChallengeId.Value);
        userCredential.HashedPassword.IsNone.Should().BeTrue();
        userCredential
            .PasswordResetToken.Get()
            .Should()
            .Be(userCredentialEntity.PasswordResetToken!);
        userCredential
            .PasswordResetTokenExpireDate.Get()
            .Should()
            .Be(userCredentialEntity.PasswordResetTokenExpireDate);
        userCredential.RefreshToken.Should().Be(userCredentialEntity.RefreshToken.ToOption());
        userCredential.SignInProvider.Should().Be(userCredentialEntity.SignInProvider);
        userCredential.UserId.Value.Should().Be(userCredentialEntity.UserId);
    }
}
