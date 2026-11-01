using FluentAssertions;

using RPGTableHelper.DataLayer.Contracts.Models.Fights;
using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.Api.Tests.Services.Fights;

public class FightCharacterResolverTests
{
    private static readonly Guid OwnerId = Guid.NewGuid();
    private static readonly Guid CharacterId = Guid.NewGuid();

    [Fact]
    public void ListCombatants_FindsCharacterCompanionsAndOldAlternateForms()
    {
        // arrange
        var config = """
            {
              "uuid": "hero",
              "characterName": "Aria",
              "companionCharacters": [ { "uuid": "wolf", "characterName": "Fang" } ],
              "alternateForms": [ { "uuid": "bear", "characterName": "Aria (Bear)" } ]
            }
            """;

        // act
        var combatants = FightCharacterResolver.ListCombatants(
            new[] { new CampagneCharacter(CharacterId, OwnerId, "Stored name", config) }
        );

        // assert
        combatants.Select(c => (c.CharacterUuid, c.Name, c.Kind)).Should().Equal(
            ("hero", "Aria", FightParticipantKind.Character),
            ("wolf", "Fang", FightParticipantKind.Companion),
            ("bear", "Aria (Bear)", FightParticipantKind.Companion)
        );
        combatants.Should().OnlyContain(c => c.OwnerUserId == OwnerId && c.PlayerCharacterId == CharacterId);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("not json")]
    [InlineData("[1,2]")]
    [InlineData("{\"characterName\":\"no uuid\"}")]
    public void ListCombatants_SkipsCharactersWithoutUsableConfiguration(string? config)
    {
        // act
        var combatants = FightCharacterResolver.ListCombatants(
            new[] { new CampagneCharacter(CharacterId, OwnerId, "Stored name", config) }
        );

        // assert
        combatants.Should().BeEmpty();
    }

    [Fact]
    public void ListCombatants_FallsBackToTheStoredNameAndIgnoresDuplicateUuids()
    {
        // arrange
        var config = """{ "uuid": "hero", "companionCharacters": [ { "uuid": "hero" }, { "uuid": "owl" } ] }""";

        // act
        var combatants = FightCharacterResolver.ListCombatants(
            new[] { new CampagneCharacter(CharacterId, OwnerId, "Stored name", config) }
        );

        // assert
        combatants.Select(c => (c.CharacterUuid, c.Name)).Should().Equal(("hero", "Stored name"), ("owl", "Stored name"));
    }
}
