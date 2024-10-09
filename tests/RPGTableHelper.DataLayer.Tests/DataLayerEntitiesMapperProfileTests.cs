namespace RPGTableHelper.DataLayer.Tests;

using AutoMapper;
using FluentAssertions;
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
}
