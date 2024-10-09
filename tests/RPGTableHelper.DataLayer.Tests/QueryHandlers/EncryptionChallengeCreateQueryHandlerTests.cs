using FluentAssertions;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers;
using RPGTableHelper.DataLayer.Tests.QueryHandlers.Base;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public class EncryptionChallengeCreateQueryHandlerTests : QueryHandlersTestBase
{
    [Fact]
    public async Task RunQueryAsync_CreatesModelSuccessfully()
    {
        // Arrange
        var model = new EncryptionChallenge
        {
            Id = EncryptionChallenge.EncryptionChallengeIdentifier.From(Guid.Empty),
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
