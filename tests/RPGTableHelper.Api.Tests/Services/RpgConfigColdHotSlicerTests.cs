using System.Text.Json;

using FluentAssertions;

using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Services;

public class RpgConfigColdHotSlicerTests
{
    [Fact]
    public void SliceFromLegacyFull_SplitsKnownKeysIntoColdAndHot()
    {
        var legacy =
            """
            {
              "rpgName":"MyGame",
              "allItems":[{"uuid":"i1","name":"Item1"}],
              "placesOfFindings":[{"uuid":"p1","name":"Place1"}],
              "currencyDefinition":{"currencyTypes":[{"name":"Gold","multipleOfPreviousValue":null}]},
              "itemCategories":[],
              "characterStatTabsDefinition":null,
              "craftingRecipes":[]
            }
            """;

        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(legacy);

        using var cold = JsonDocument.Parse(slices.ColdJson);
        using var hot = JsonDocument.Parse(slices.HotJson);

        cold.RootElement.TryGetProperty("allItems", out _).Should().BeTrue();
        cold.RootElement.TryGetProperty("placesOfFindings", out _).Should().BeTrue();
        cold.RootElement.TryGetProperty("currencyDefinition", out _).Should().BeTrue();

        hot.RootElement.TryGetProperty("rpgName", out var rpgName).Should().BeTrue();
        rpgName.GetString().Should().Be("MyGame");
    }

    [Fact]
    public void SliceFromLegacyFull_UnknownKeys_ArePreservedInHot()
    {
        var legacy =
            """
            {
              "rpgName":"MyGame",
              "allItems":[],
              "mysteryNewKey":{"x":1}
            }
            """;

        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(legacy);

        using var hot = JsonDocument.Parse(slices.HotJson);
        hot.RootElement.TryGetProperty("mysteryNewKey", out var v).Should().BeTrue();
        v.GetProperty("x").GetInt32().Should().Be(1);
    }

    [Fact]
    public void MergeToLegacyFull_HotWinsOnConflicts_AndRoundTrips()
    {
        var cold = """{"rpgName":"coldName","allItems":[{"uuid":"i1"}]}""";
        var hot = """{"rpgName":"hotName","extra":true}""";

        var merged = RpgConfigColdHotSlicer.MergeToLegacyFull(cold, hot);

        NormalizeJson(merged).Should().Be(NormalizeJson("""{"rpgName":"hotName","allItems":[{"uuid":"i1"}],"extra":true}"""));
    }

    private static string NormalizeJson(string json)
    {
        using var doc = JsonDocument.Parse(json);
        return JsonSerializer.Serialize(doc.RootElement);
    }
}
