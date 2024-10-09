using FluentAssertions;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers.Encryptions;

public class EncryptionChallengeCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory, Mapper);

        var model = new EncryptionChallenge
        {
            Id = EncryptionChallenge.EncryptionChallengeIdentifier.From(Guid.Empty),
            UserId = user.Id,
            RndInt = 1234567,
            PasswordPrefix = "Bla",
        };

        var query = new EncryptionChallengeCreateQuery { ModelToCreate = model };
        var subjectUnderTest = new EncryptionChallengeCreateQueryHandler(
            Mapper,
            ContextFactory,
            SystemClock
        );

        // Act
        var result = await subjectUnderTest.RunQueryAsync(query, default);

        // Assert
        result.IsSome.Should().BeTrue("because the creation should be successful");

        var entities = Context.EncryptionChallenges.ToList();
        entities.Should().HaveCount(1);
        entities[0].PasswordPrefix.Should().Be("Bla");
        entities[0].RndInt.Should().Be(1234567);

        AssertCorrectTime(entities[0].CreationDate);
        AssertCorrectTime(entities[0].LastModifiedAt);
    }
}
