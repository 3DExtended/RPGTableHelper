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
}
