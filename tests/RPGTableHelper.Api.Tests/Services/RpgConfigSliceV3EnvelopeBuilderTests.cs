using System.Text.Json;
using System.Text.Json.Nodes;

using FluentAssertions;

using Json.Patch;

using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Services;

public class RpgConfigSliceV3EnvelopeBuilderTests
{
    [Fact]
    public void BuildEnvelope_FirstSlice_UsesFullEvenWithFromRevisionZero()
    {
        const string newJson = """{"a":1,"b":2}""";
        var envJson = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope("cold", null, newJson, 0, 1);
        using var doc = JsonDocument.Parse(envJson);
        doc.RootElement.GetProperty("kind").GetString().Should().Be("full");
        doc.RootElement.GetProperty("slice").GetString().Should().Be("cold");
        doc.RootElement.GetProperty("revision").GetInt32().Should().Be(1);
    }

    [Fact]
    public void BuildEnvelope_SmallPatch_IsSmallerThanFull_UsesPatch()
    {
        // Removing one top-level key yields a tiny patch vs re-sending a fat object.
        const string oldJson = """{"keep":true,"drop":false,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}""";
        const string newJson = """{"keep":true,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}""";
        var envJson = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope("hot", oldJson, newJson, 3, 4);
        using var doc = JsonDocument.Parse(envJson);
        doc.RootElement.GetProperty("kind").GetString().Should().Be("patch");
        doc.RootElement.GetProperty("fromRevision").GetInt32().Should().Be(3);
        doc.RootElement.GetProperty("toRevision").GetInt32().Should().Be(4);

        var patch = doc.RootElement.GetProperty("patch");
        var oldNode = JsonNode.Parse(oldJson)!;
        var deserialized = JsonSerializer.Deserialize<JsonPatch>(patch.GetRawText());
        deserialized.Should().NotBeNull();
        var patchResult = deserialized!.Apply(oldNode);
        patchResult.IsSuccess.Should().BeTrue();
        JsonNode.Parse(newJson)!.ToJsonString().Should().Be(patchResult.Result!.ToJsonString());
    }

    [Fact]
    public void BuildFullEnvelope_RoundTripsBody()
    {
        const string slice = """{"k":"v"}""";
        var envJson = RpgConfigSliceV3EnvelopeBuilder.BuildFullEnvelope("cold", 7, slice);
        using var doc = JsonDocument.Parse(envJson);
        doc.RootElement.GetProperty("kind").GetString().Should().Be("full");
        doc.RootElement.GetProperty("revision").GetInt32().Should().Be(7);
        doc.RootElement.GetProperty("body").GetProperty("k").GetString().Should().Be("v");
    }
}
