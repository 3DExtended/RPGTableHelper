using System.Diagnostics.CodeAnalysis;
using System.Text.Json;
using System.Text.Json.Nodes;

using Json.Patch;

namespace RPGTableHelper.WebApi.Services.ConfigRevisions;

/// <summary>
/// Applies RFC 6902 JSON Patch documents to config JSON strings, and builds top-level JSON Patch
/// documents describing the difference between two config JSON strings (used for revisioned GETs).
/// </summary>
public static class ConfigDocumentPatcher
{
    /// <summary>Shared serializer options for config revision wire payloads.</summary>
    public static readonly JsonSerializerOptions SerializerOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };

    /// <summary>
    /// Applies a RFC 6902 JSON Patch document (serialized as a JSON array string) to <paramref name="baseJson"/>.
    /// </summary>
    public static bool TryApply(
        string? baseJson,
        string patchJson,
        [NotNullWhen(true)] out string? resultJson,
        [NotNullWhen(false)] out string? error
    )
    {
        resultJson = null;
        error = null;

        JsonPatch? patch;
        try
        {
            patch = JsonSerializer.Deserialize<JsonPatch>(patchJson);
        }
        catch (JsonException ex)
        {
            error = ex.Message;
            return false;
        }

        if (patch is null)
        {
            error = "Patch document is empty.";
            return false;
        }

        JsonNode baseNode;
        try
        {
            baseNode = JsonNode.Parse(string.IsNullOrWhiteSpace(baseJson) ? "{}" : baseJson)!;
        }
        catch (JsonException ex)
        {
            error = ex.Message;
            return false;
        }

        var patchResult = patch.Apply(baseNode);
        if (!patchResult.IsSuccess)
        {
            error = patchResult.Error ?? "Patch could not be applied.";
            return false;
        }

        resultJson = (patchResult.Result ?? new JsonObject()).ToJsonString(SerializerOptions);
        return true;
    }

    /// <summary>
    /// Builds a top-level RFC 6902 JSON Patch document (as a JSON array string) describing how to turn
    /// <paramref name="fromJson"/> into <paramref name="toJson"/>. Both documents must be JSON objects.
    /// Returns <c>null</c> if either document is not a JSON object (caller should fall back to a full document).
    /// </summary>
    public static string? TryBuildTopLevelPatch(string? fromJson, string? toJson)
    {
        JsonDocument fromDoc;
        JsonDocument toDoc;
        try
        {
            fromDoc = JsonDocument.Parse(string.IsNullOrWhiteSpace(fromJson) ? "{}" : fromJson);
            toDoc = JsonDocument.Parse(string.IsNullOrWhiteSpace(toJson) ? "{}" : toJson);
        }
        catch (JsonException)
        {
            return null;
        }

        using (fromDoc)
        using (toDoc)
        {
            if (fromDoc.RootElement.ValueKind != JsonValueKind.Object || toDoc.RootElement.ValueKind != JsonValueKind.Object)
            {
                return null;
            }

            var fromProps = fromDoc.RootElement.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);
            var toProps = toDoc.RootElement.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);

            var patch = new JsonArray();

            foreach (var kv in fromProps)
            {
                if (!toProps.ContainsKey(kv.Key))
                {
                    patch.Add(new JsonObject { ["op"] = "remove", ["path"] = "/" + EscapeJsonPointerSegment(kv.Key) });
                }
            }

            foreach (var kv in toProps)
            {
                if (!fromProps.TryGetValue(kv.Key, out var fromValue))
                {
                    patch.Add(
                        new JsonObject
                        {
                            ["op"] = "add",
                            ["path"] = "/" + EscapeJsonPointerSegment(kv.Key),
                            ["value"] = JsonNode.Parse(kv.Value.GetRawText())!,
                        }
                    );
                }
                else if (fromValue.GetRawText() != kv.Value.GetRawText())
                {
                    patch.Add(
                        new JsonObject
                        {
                            ["op"] = "replace",
                            ["path"] = "/" + EscapeJsonPointerSegment(kv.Key),
                            ["value"] = JsonNode.Parse(kv.Value.GetRawText())!,
                        }
                    );
                }
            }

            return patch.ToJsonString(SerializerOptions);
        }
    }

    private static string EscapeJsonPointerSegment(string token) =>
        token.Replace("~", "~0", StringComparison.Ordinal).Replace("/", "~1", StringComparison.Ordinal);
}
