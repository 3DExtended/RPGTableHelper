using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using FluentAssertions;
using RPGTableHelper.BusinessLayer.Contracts.Models;
using RPGTableHelper.BusinessLayer.QueryHandlers;
using Xunit;

namespace RPGTableHelper.BusinessLayer.Tests;

public class JsonDifferTests
{
    public static JsonNode Parse(string json) => JsonNode.Parse(json)!;

    [Fact]
    public void Should_Add_And_Remove_Properties()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""name"": ""Alice"",
                ""age"": 30
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""name"": ""Alice"",
                ""email"": ""alice@example.com""
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);

        patch.Should().HaveCount(3);
        patch[0]["op"]!.ToString().Should().Be("version");
        patch[1]["op"]!.ToString().Should().Be("remove");
        patch[1]["path"]!.ToString().Should().Be("/age");
        patch[2]["op"]!.ToString().Should().Be("add");
        patch[2]["path"]!.ToString().Should().Be("/email");

        var updated = JsonDiffer.Apply(oldJson, patch);

        updated["email"]!.ToString().Should().Be("alice@example.com");
        updated.AsObject().ContainsKey("age").Should().BeFalse();
        updated["version"]!.GetValue<int>().Should().Be(2);
    }

    [Fact]
    public void Should_Replace_Nested_Value()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""user"": { ""city"": ""Paris"" }
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""user"": { ""city"": ""Berlin"" }
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);
        patch.Should().Contain(p => p.ContainsKey("path") && p["path"]!.ToString() == "/user/city");

        var updated = JsonDiffer.Apply(oldJson, patch);
        updated["user"]!["city"]!.ToString().Should().Be("Berlin");
        updated["version"]!.GetValue<int>().Should().Be(2);
    }

    [Fact]
    public void Should_Serialize_And_Deserialize_Patch()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""user"": { ""city"": ""Paris"" }
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""user"": { ""city"": ""Berlin"" }
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);

        // Serialize the patch to JSON
        var wrappedPatch = new JsonObject { ["Operations"] = new JsonArray(patch.ToArray()) };
        var serializedPatch = wrappedPatch.ToJsonString();

        // Deserialize the patch back to a list of JsonObject
        var action = () => JsonSerializer.Deserialize<JsonPatchRequest>(serializedPatch);
        action.Should().NotThrow();
    }

    [Fact]
    public void Should_Add_And_Remove_Array_Elements()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""tags"": [""a"", ""b"", ""c""]
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""tags"": [""a"", ""c"", ""d""]
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);
        var updated = JsonDiffer.Apply(oldJson, patch);

        var tags = updated["tags"]!.AsArray();
        tags.Select(t => t!.ToString()).Should().BeEquivalentTo("a", "c", "d");
        updated["version"]!.GetValue<int>().Should().Be(2);
    }

    [Fact]
    public void Should_Replace_Object_With_Primitive()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""value"": { ""a"": 1 }
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""value"": ""hello""
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);
        patch.Should().ContainSingle(p => p["op"]!.ToString() == "replace" && p["path"]!.ToString() == "/value");

        var updated = JsonDiffer.Apply(oldJson, patch);
        updated["value"]!.ToString().Should().Be("hello");
    }

    [Fact]
    public void Should_Generate_Only_Version_When_No_Changes()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""data"": 123
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""data"": 123
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);
        patch.Should().ContainSingle().Which["op"]!.ToString().Should().Be("version");

        var updated = JsonDiffer.Apply(oldJson, patch);
        updated["version"]!.GetValue<int>().Should().Be(2);
    }

    [Fact]
    public void Should_Throw_If_Missing_Version_Operation()
    {
        var original = Parse(
            @"{
                ""version"": 1,
                ""x"": 1
            }"
        );

        var invalidPatch = new List<JsonObject>
        {
            new JsonObject
            {
                ["op"] = "replace",
                ["path"] = "/x",
                ["value"] = 2,
            },
        };

        Action act = () => JsonDiffer.Apply(original, invalidPatch);
        act.Should().Throw<Exception>().WithMessage("*version*");
    }

    [Fact]
    public void Should_Throw_On_Version_Mismatch()
    {
        var original = Parse(
            @"{
                ""version"": 3,
                ""x"": 1
            }"
        );

        var patch = new List<JsonObject>
        {
            new JsonObject
            {
                ["op"] = "version",
                ["from"] = 2,
                ["to"] = 3,
            },
            new JsonObject
            {
                ["op"] = "replace",
                ["path"] = "/x",
                ["value"] = 2,
            },
        };

        Action act = () => JsonDiffer.Apply(original, patch);
        act.Should().Throw<Exception>().WithMessage("*mismatch*");
    }

    [Fact]
    public void Should_Handle_Multiple_Object_And_Array_Changes()
    {
        var oldJson = Parse(
            @"{
                ""version"": 1,
                ""a"": 1,
                ""b"": [1, 2],
                ""c"": { ""x"": true }
            }"
        );

        var newJson = Parse(
            @"{
                ""version"": 2,
                ""a"": 2,
                ""b"": [1, 3, 4],
                ""c"": { ""x"": false, ""y"": ""yes"" }
            }"
        );

        var patch = JsonDiffer.Diff(oldJson, newJson);
        var updated = JsonDiffer.Apply(oldJson, patch);

        updated["a"]!.GetValue<int>().Should().Be(2);
        updated["b"]!.AsArray().Select(x => x!.ToString()).Should().BeEquivalentTo("1", "3", "4");
        updated["c"]!["x"]!.GetValue<bool>().Should().BeFalse();
        updated["c"]!["y"]!.ToString().Should().Be("yes");
        updated["version"]!.GetValue<int>().Should().Be(2);
    }
}
