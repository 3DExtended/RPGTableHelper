using FluentAssertions;

using RPGTableHelper.WebApi.Services.ConfigRevisions;

namespace RPGTableHelper.Api.Tests.Services.ConfigRevisions;

public class ConfigDocumentPatcherTests
{
    [Fact]
    public void TryApply_ShouldApplyReplaceOperation()
    {
        // act
        var success = ConfigDocumentPatcher.TryApply(
            "{\"name\":\"old\"}",
            "[{\"op\":\"replace\",\"path\":\"/name\",\"value\":\"new\"}]",
            out var resultJson,
            out var error
        );

        // assert
        success.Should().BeTrue();
        error.Should().BeNull();
        resultJson.Should().Be("{\"name\":\"new\"}");
    }

    [Fact]
    public void TryApply_ShouldFailOnMalformedPatchJson()
    {
        // act
        var success = ConfigDocumentPatcher.TryApply(
            "{\"name\":\"old\"}",
            "not valid json",
            out var resultJson,
            out var error
        );

        // assert
        success.Should().BeFalse();
        resultJson.Should().BeNull();
        error.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public void TryApply_ShouldFailWhenPathDoesNotExistForReplace()
    {
        // act
        var success = ConfigDocumentPatcher.TryApply(
            "{\"name\":\"old\"}",
            "[{\"op\":\"replace\",\"path\":\"/missing/nested\",\"value\":\"new\"}]",
            out var resultJson,
            out var error
        );

        // assert
        success.Should().BeFalse();
        resultJson.Should().BeNull();
        error.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public void TryBuildTopLevelPatch_ShouldDescribeAddedRemovedAndReplacedTopLevelKeys()
    {
        // act
        var patchJson = ConfigDocumentPatcher.TryBuildTopLevelPatch(
            "{\"a\":1,\"b\":2}",
            "{\"a\":9,\"c\":3}"
        );

        // assert
        patchJson.Should().NotBeNull();
        patchJson.Should().Contain("\"op\":\"remove\"").And.Contain("\"path\":\"/b\"");
        patchJson.Should().Contain("\"op\":\"add\"").And.Contain("\"path\":\"/c\"");
        patchJson.Should().Contain("\"op\":\"replace\"").And.Contain("\"path\":\"/a\"");
    }

    [Fact]
    public void TryBuildTopLevelPatch_ShouldReturnNullWhenEitherDocumentIsNotAnObject()
    {
        // act
        var patchJson = ConfigDocumentPatcher.TryBuildTopLevelPatch("[1,2,3]", "{\"a\":1}");

        // assert
        patchJson.Should().BeNull();
    }

    [Fact]
    public void TryBuildTopLevelPatch_ShouldReturnEmptyArrayWhenDocumentsAreIdentical()
    {
        // act
        var patchJson = ConfigDocumentPatcher.TryBuildTopLevelPatch("{\"a\":1}", "{\"a\":1}");

        // assert
        patchJson.Should().Be("[]");
    }
}
