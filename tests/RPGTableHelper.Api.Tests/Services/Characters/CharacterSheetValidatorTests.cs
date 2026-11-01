using System.Text.Json.Nodes;

using FluentAssertions;

using RPGTableHelper.WebApi.Services.Characters;

namespace RPGTableHelper.Api.Tests.Services.Characters;

public class CharacterSheetValidatorTests
{
    private const string Config = """
        {
          "characterStatTabsDefinition": [
            { "statsInTab": [
              { "statUuid": "hp", "valueType": "intWithMaxValue" },
              { "statUuid": "bio", "valueType": "multiLineText" },
              { "statUuid": "skills", "valueType": "multiselect" },
              { "statUuid": "attrs", "valueType": "listOfIntWithCalculatedValues" }
            ] }
          ]
        }
        """;

    [Fact]
    public void ReadStatTypes_ReadsEveryStatOfEveryTab()
    {
        CharacterSheetValidator.ReadStatTypes(Config).Should().BeEquivalentTo(
            new Dictionary<string, string>
            {
                ["hp"] = "intWithMaxValue",
                ["bio"] = "multiLineText",
                ["skills"] = "multiselect",
                ["attrs"] = "listOfIntWithCalculatedValues",
            }
        );
    }

    [Fact]
    public void Validate_AWellFormedSheet_HasNoProblems()
    {
        var sheet = Sheet(
            Stat("hp", new JsonObject { ["value"] = 3, ["maxValue"] = 10 }),
            Stat("bio", new JsonObject { ["value"] = "Brave" }),
            Stat("skills", new JsonObject { ["values"] = new JsonArray("a", "b") }),
            Stat("attrs", new JsonObject { ["values"] = new JsonArray(new JsonObject { ["uuid"] = "str", ["value"] = 12 }) })
        );

        CharacterSheetValidator.Validate(sheet, CharacterSheetValidator.ReadStatTypes(Config)).Should().BeEmpty();
    }

    [Theory]
    [InlineData("hp", """{"value":"3","maxValue":10}""")]
    [InlineData("hp", """{"value":3.5,"maxValue":10}""")]
    [InlineData("bio", """{"value":7}""")]
    [InlineData("skills", """{"values":"a"}""")]
    [InlineData("attrs", """{"values":[{"uuid":"str","value":"high"}]}""")]
    public void Validate_AValueThatDoesNotFitItsType_IsAProblem(string statUuid, string serializedValue)
    {
        var sheet = Sheet(new JsonObject { ["statUuid"] = statUuid, ["serializedValue"] = serializedValue });

        CharacterSheetValidator.Validate(sheet, CharacterSheetValidator.ReadStatTypes(Config))
            .Should().ContainSingle(p => p.Contains($"statUuid={statUuid}"));
    }

    [Fact]
    public void Validate_AStatTheCampaignDoesNotKnow_IsAProblem()
    {
        var sheet = Sheet(Stat("unknown", new JsonObject { ["value"] = 1 }));

        CharacterSheetValidator.Validate(sheet, CharacterSheetValidator.ReadStatTypes(Config))
            .Should().ContainSingle(p => p.Contains("statUuid=unknown"));
    }

    [Fact]
    public void Validate_WithoutAConfig_OnlyChecksTheShape()
    {
        var sheet = Sheet(Stat("anything", new JsonObject { ["value"] = "whatever" }));

        CharacterSheetValidator.Validate(sheet, CharacterSheetValidator.ReadStatTypes(null)).Should().BeEmpty();
    }

    [Fact]
    public void Validate_ASheetWithoutUuidOrStats_HasProblems()
    {
        CharacterSheetValidator.Validate("""{"characterName":"X"}""", new Dictionary<string, string>())
            .Should().Contain(p => p.StartsWith("/uuid")).And.Contain(p => p.StartsWith("/characterStats"));
    }

    [Fact]
    public void FindNewProblems_IgnoresProblemsTheSheetAlreadyHad()
    {
        var broken = Stat("hp", new JsonObject { ["value"] = "broken" });
        var before = Sheet(broken);
        var after = Sheet(broken.DeepClone().AsObject(), Stat("bio", new JsonObject { ["value"] = "New" }));

        CharacterSheetValidator.FindNewProblems(before, after, Config).Should().BeEmpty();
    }

    [Fact]
    public void FindNewProblems_FindsAChangedUuid()
    {
        var before = Sheet();
        var after = JsonNode.Parse(before)!.AsObject();
        after["uuid"] = "other";

        CharacterSheetValidator.FindNewProblems(before, after.ToJsonString(), Config)
            .Should().ContainSingle(p => p.StartsWith("/uuid"));
    }

    [Fact]
    public void FindNewProblems_FindsABrokenCompanionStat()
    {
        var before = Sheet();
        var after = JsonNode.Parse(before)!.AsObject();
        after["companionCharacters"] = new JsonArray(
            new JsonObject
            {
                ["uuid"] = "wolf",
                ["characterName"] = "Wolf",
                ["characterStats"] = new JsonArray(Stat("hp", new JsonObject { ["value"] = 1 })),
            }
        );

        CharacterSheetValidator.FindNewProblems(before, after.ToJsonString(), Config)
            .Should().ContainSingle(p => p.StartsWith("/companionCharacters[uuid=wolf]"));
    }

    [Fact]
    public void FindNewProblems_FindsABrokenStatOfTheActiveForm()
    {
        var before = Sheet();
        var after = JsonNode.Parse(before)!.AsObject();
        after["alternateForm"] = new JsonObject
        {
            ["uuid"] = "bear",
            ["characterName"] = "Bear",
            ["characterStats"] = new JsonArray(Stat("hp", new JsonObject { ["value"] = "big" })),
        };

        CharacterSheetValidator.FindNewProblems(before, after.ToJsonString(), Config)
            .Should().ContainSingle(p => p.StartsWith("/alternateForm/characterStats[statUuid=hp]"));
    }

    private static JsonObject Stat(string statUuid, JsonObject value) =>
        new() { ["statUuid"] = statUuid, ["serializedValue"] = value.ToJsonString() };

    private static string Sheet(params JsonObject[] stats) =>
        new JsonObject
        {
            ["uuid"] = "hero",
            ["characterName"] = "Hero",
            ["characterStats"] = new JsonArray(stats.Select(s => (JsonNode)s).ToArray()),
        }.ToJsonString();
}
