using System.Text.Json;

using FluentAssertions;

using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Services;

public class RpgConfigSliceV3UpstreamEnvelopeTests
{
    [Fact]
    public void TryResolve_FullUpstream_ExtractsBody()
    {
        const string env = """{"kind":"full","slice":"cold","body":{"a":1}}""";
        var ok = RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
            env,
            "cold",
            "{}",
            0,
            out var resolved,
            out var err
        );
        ok.Should().BeTrue();
        err.Should().BeNull();
        using var doc = JsonDocument.Parse(resolved!);
        doc.RootElement.GetProperty("a").GetInt32().Should().Be(1);
    }

    [Fact]
    public void TryResolve_Patch_AppliesToCurrentJson()
    {
        const string oldJson = """{"keep":true,"drop":false}""";
        const string newJson = """{"keep":true}""";
        var patchEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope("hot", oldJson, newJson, 2, 3);
        var ok = RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
            patchEnv,
            "hot",
            oldJson,
            2,
            out var resolved,
            out var err
        );
        ok.Should().BeTrue();
        err.Should().BeNull();
        using var doc = JsonDocument.Parse(resolved!);
        doc.RootElement.TryGetProperty("drop", out _).Should().BeFalse();
        doc.RootElement.GetProperty("keep").GetBoolean().Should().BeTrue();
    }

    [Fact]
    public void TryResolve_Patch_WrongFromRevision_Fails()
    {
        const string oldJson = """{"keep":true,"drop":false,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}""";
        const string newJson = """{"keep":true,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}""";
        var patchEnv = RpgConfigSliceV3EnvelopeBuilder.BuildEnvelope("cold", oldJson, newJson, 5, 6);
        patchEnv.Should().Contain("patch");
        var ok = RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
            patchEnv,
            "cold",
            oldJson,
            4,
            out _,
            out var err
        );
        ok.Should().BeFalse();
        err.Should().Contain("fromRevision");
    }

    [Fact]
    public void TryResolve_MergedFull_ExtractsBody()
    {
        const string env = """{"kind":"full","slice":"merged","body":{"x":2}}""";
        var ok = RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
            env,
            "merged",
            "{}",
            0,
            out var resolved,
            out _
        );
        ok.Should().BeTrue();
        using var doc = JsonDocument.Parse(resolved!);
        doc.RootElement.GetProperty("x").GetInt32().Should().Be(2);
    }

    [Fact]
    public void TryResolve_SliceMismatch_Fails()
    {
        const string env = """{"kind":"full","slice":"hot","body":{}}""";
        var ok = RpgConfigSliceV3UpstreamEnvelope.TryResolveSlicePayload(
            env,
            "cold",
            "{}",
            0,
            out _,
            out _
        );
        ok.Should().BeFalse();
    }
}
