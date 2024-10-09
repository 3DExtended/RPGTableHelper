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
        var user = new EncryptionChallenge
        {
            PasswordPrefix = "TestEncryptionChallenge",
            RndInt = 34567,
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 2, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2023, 10, 10, 10, 10, 2, TimeSpan.Zero),
            Id = EncryptionChallenge.EncryptionChallengeIdentifier.From(Guid.NewGuid()),
        };

        // Act
        var userEntity = _mapper.Map<EncryptionChallengeEntity>(user);

        // Assert
        userEntity.Should().NotBeNull();
        userEntity.PasswordPrefix.Should().Be(user.PasswordPrefix);
        userEntity.RndInt.Should().Be(user.RndInt);
        userEntity.Id.Should().Be(user.Id.Value);
        userEntity.CreationDate.Should().Be(user.CreationDate);
        userEntity.LastModifiedAt.Should().Be(user.LastModifiedAt);
    }

    [Fact]
    public void EncryptionChallengeEntityToEncryptionChallenge_ShouldMapSuccessfully()
    {
        // Arrange
        var userEntity = new EncryptionChallengeEntity
        {
            PasswordPrefix = "TestEncryptionChallengeEntity",
            RndInt = 254321,
            Id = Guid.NewGuid(),
            CreationDate = DateTimeOffset.UtcNow,
            LastModifiedAt = DateTimeOffset.UtcNow,
        };

        // Act
        var user = _mapper.Map<EncryptionChallenge>(userEntity);

        // Assert
        user.Should().NotBeNull();
        user.PasswordPrefix.Should().Be(userEntity.PasswordPrefix);
        user.RndInt.Should().Be(userEntity.RndInt);
        user.Id.Value.Should().Be(userEntity.Id);
        user.CreationDate.Should().Be(userEntity.CreationDate);
        user.LastModifiedAt.Should().Be(userEntity.LastModifiedAt);
    }
}
