using System.Text.Json;

using FluentAssertions;

using RPGTableHelper.Api.Tests.TestData;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Services;

/// <summary>
/// Regression tests using committed production backup JSON under /liveBackups.
/// </summary>
public class RpgConfigColdHotSlicerLiveBackupsTests
{
    public static TheoryData<string> BackupFileNames()
    {
        var data = new TheoryData<string>();
        foreach (var name in LiveBackupTestPaths.AllBackupFileNames)
        {
            data.Add(name);
        }

        return data;
    }

    public static TheoryData<string> CharacterBackupFileNames()
    {
        var data = new TheoryData<string>();
        foreach (var name in LiveBackupTestPaths.AllBackupFileNames)
        {
            if (name != LiveBackupTestPaths.CampaignRpgConfiguration)
            {
                data.Add(name);
            }
        }

        return data;
    }

    [Theory]
    [MemberData(nameof(BackupFileNames))]
    public void SliceFromLegacyFull_MergeToLegacyFull_RoundTrips(string fileName)
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();
        var legacy = LiveBackupTestPaths.ReadAllText(fileName);
        legacy.Should().NotBeNullOrWhiteSpace();

        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(legacy);
        slices.SchemaVersion.Should().Be(RpgConfigColdHotSlicer.SchemaVersion);

        var merged = RpgConfigColdHotSlicer.MergeToLegacyFull(slices.ColdJson, slices.HotJson);
        LiveBackupTestPaths.JsonDeepEquals(merged, legacy).Should().BeTrue();
    }

    [Fact]
    public void ProdCampaignBackup_ColdContains_ItemCatalog_AndHotContains_RpgName()
    {
        var legacy = LiveBackupTestPaths.ReadAllText(LiveBackupTestPaths.CampaignRpgConfiguration);
        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(legacy);

        using var cold = JsonDocument.Parse(slices.ColdJson);
        cold.RootElement.TryGetProperty("allItems", out _).Should().BeTrue();
        cold.RootElement.TryGetProperty("currencyDefinition", out _).Should().BeTrue();

        using var hot = JsonDocument.Parse(slices.HotJson);
        hot.RootElement.TryGetProperty("rpgName", out _).Should().BeTrue();
    }

    [Theory]
    [MemberData(nameof(CharacterBackupFileNames))]
    public void CharacterShapedBackups_AllNonColdKeys_LandInHotSlice(string fileName)
    {
        var legacy = LiveBackupTestPaths.ReadAllText(fileName);
        var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(legacy);

        slices.ColdJson.Should().Be("{}");
        using var hot = JsonDocument.Parse(slices.HotJson);
        hot.RootElement.TryGetProperty("characterName", out _).Should().BeTrue();
        hot.RootElement.TryGetProperty("uuid", out _).Should().BeTrue();
    }
}
