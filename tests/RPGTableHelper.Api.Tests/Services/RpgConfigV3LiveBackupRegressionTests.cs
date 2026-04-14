using System.Text.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Json.Patch;

using RPGTableHelper.Api.Tests.TestData;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Services;

public class RpgConfigV3LiveBackupRegressionTests
{
    [Fact]
    public void LiveBackups_CanSliceAndMerge_WithoutDataLoss()
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();

        foreach (var fileName in LiveBackupTestPaths.AllBackupFileNames)
        {
            var json = LiveBackupTestPaths.ReadAllText(fileName);
            var slices = RpgConfigColdHotSlicer.SliceFromLegacyFull(json);
            var merged = RpgConfigColdHotSlicer.MergeToLegacyFull(slices.ColdJson, slices.HotJson);

            LiveBackupTestPaths.JsonDeepEquals(json, merged)
                .Should()
                .BeTrue($"slice/merge should preserve JSON for {fileName}");
        }
    }

    [Fact]
    public void LiveBackups_V3EnvelopeBuilder_NeverCreatesInvalidPatch()
    {
        Directory.Exists(Path.Combine(AppContext.BaseDirectory, "liveBackups")).Should().BeTrue();

        foreach (var fileName in LiveBackupTestPaths.AllBackupFileNames)
        {
            var oldJson = LiveBackupTestPaths.ReadAllText(fileName);

            JsonNode? oldNode;
            try
            {
                oldNode = JsonNode.Parse(oldJson);
            }
            catch (JsonException)
            {
                // Some character backups may contain legacy/partial JSON; skip.
                continue;
            }

            if (oldNode is not JsonObject oldObj || oldObj.Count == 0)
            {
                continue;
            }

            // Remove one arbitrary top-level key to get a deterministic "small change".
            var keyToRemove = oldObj.First().Key;
            var newObj = (JsonObject)oldObj.DeepClone();
            newObj.Remove(keyToRemove);
            var newJson = newObj.ToJsonString();

            var env = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope(
                "merged",
                oldJson,
                newJson,
                fromRevision: 7,
                toRevision: 8
            );

            using var doc = JsonDocument.Parse(env);
            var kind = doc.RootElement.GetProperty("kind").GetString();
            kind.Should().BeOneOf("full", "patch");

            if (kind == "patch")
            {
                var patchEl = doc.RootElement.GetProperty("patch");
                var patch = JsonSerializer.Deserialize<JsonPatch>(patchEl.GetRawText());
                patch.Should().NotBeNull();

                var patched = patch!.Apply(oldObj.DeepClone());
                patched.IsSuccess.Should().BeTrue($"patch should apply for {fileName}");
                LiveBackupTestPaths.JsonDeepEquals(patched.Result!.ToJsonString(), newJson).Should().BeTrue();
            }
            else
            {
                var body = doc.RootElement.GetProperty("body").GetRawText();
                LiveBackupTestPaths.JsonDeepEquals(body, newJson).Should().BeTrue();
            }
        }
    }
}
