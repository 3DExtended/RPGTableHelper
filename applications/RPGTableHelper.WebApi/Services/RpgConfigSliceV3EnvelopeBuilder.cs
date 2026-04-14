using System.Text.Json;
using System.Text.Json.Nodes;

namespace RPGTableHelper.WebApi.Services;

/// <summary>
/// Builds SignalR v3 JSON envelopes for RPG config cold/hot slices and player character JSON (full document or RFC 6902 top-level patch).
/// </summary>
public static class RpgConfigSliceV3EnvelopeBuilder
{
    /// <summary>Shared serializer options for v3 envelopes (server → client and client → server).</summary>
    public static readonly JsonSerializerOptions SerializerOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull,
    };

    /// <summary>
    /// Builds a serialized envelope for clients with protocol v3. Prefers a patch when it is smaller than the full slice UTF-8 payload.
    /// </summary>
    /// <param name="slice">"cold", "hot", or "character".</param>
    /// <param name="previousJson">Slice JSON before the mutation (may be null).</param>
    /// <param name="newJson">Slice JSON after the mutation.</param>
    /// <param name="fromRevision">Revision the client must have before applying a patch.</param>
    /// <param name="toRevision">Revision after applying this update.</param>
    /// <returns>Serialized JSON string for one SignalR message.</returns>
    public static string BuildEnvelope(
        string slice,
        string? previousJson,
        string newJson,
        int fromRevision,
        int toRevision
    )
    {
        if (string.IsNullOrWhiteSpace(newJson))
        {
            newJson = "{}";
        }

        if (fromRevision <= 0 || string.IsNullOrWhiteSpace(previousJson))
        {
            return SerializeFull(slice, toRevision, newJson);
        }

        if (!TryBuildTopLevelPatch(previousJson, newJson, out var patchArray) || patchArray is null || patchArray.Count == 0)
        {
            return SerializeFull(slice, toRevision, newJson);
        }

        var patchUtf8 = JsonSerializer.SerializeToUtf8Bytes(patchArray, SerializerOptions);
        var fullUtf8 = JsonSerializer.SerializeToUtf8Bytes(JsonDocument.Parse(newJson).RootElement, SerializerOptions);

        if (patchUtf8.Length >= fullUtf8.Length)
        {
            return SerializeFull(slice, toRevision, newJson);
        }

        var envelope = new JsonObject
        {
            ["kind"] = "patch",
            ["slice"] = slice,
            ["fromRevision"] = fromRevision,
            ["toRevision"] = toRevision,
            ["patch"] = patchArray,
        };

        return envelope.ToJsonString(SerializerOptions);
    }

    /// <summary>
    /// Full snapshot envelope (join, resync, or patch larger than body).
    /// </summary>
    public static string BuildFullEnvelope(string slice, int revision, string sliceJson)
    {
        if (string.IsNullOrWhiteSpace(sliceJson))
        {
            sliceJson = "{}";
        }

        return SerializeFull(slice, revision, sliceJson);
    }

    private static string SerializeFull(string slice, int revision, string sliceJson)
    {
        var body = JsonNode.Parse(sliceJson)!;
        var envelope = new JsonObject
        {
            ["kind"] = "full",
            ["slice"] = slice,
            ["revision"] = revision,
            ["body"] = body,
        };

        return envelope.ToJsonString(SerializerOptions);
    }

    private static bool TryBuildTopLevelPatch(string oldJson, string newJson, out JsonArray? patchArray)
    {
        patchArray = null;
        JsonDocument oldDoc;
        JsonDocument newDoc;
        try
        {
            oldDoc = JsonDocument.Parse(oldJson);
            newDoc = JsonDocument.Parse(newJson);
        }
        catch (JsonException)
        {
            return false;
        }

        using (oldDoc)
        using (newDoc)
        {
            if (
                oldDoc.RootElement.ValueKind != JsonValueKind.Object
                || newDoc.RootElement.ValueKind != JsonValueKind.Object
            )
            {
                return false;
            }

            var oldProps = oldDoc.RootElement.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);
            var newProps = newDoc.RootElement.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);

            var ops = new List<JsonObject>();

            foreach (var kv in oldProps)
            {
                if (!newProps.ContainsKey(kv.Key))
                {
                    ops.Add(
                        new JsonObject
                        {
                            ["op"] = "remove",
                            ["path"] = "/" + EscapeJsonPointerSegment(kv.Key),
                        }
                    );
                }
            }

            foreach (var kv in newProps)
            {
                if (!oldProps.TryGetValue(kv.Key, out var oldVal))
                {
                    ops.Add(
                        new JsonObject
                        {
                            ["op"] = "add",
                            ["path"] = "/" + EscapeJsonPointerSegment(kv.Key),
                            ["value"] = JsonNode.Parse(kv.Value.GetRawText())!,
                        }
                    );
                }
                else if (!JsonElementsEqual(oldVal, kv.Value))
                {
                    ops.Add(
                        new JsonObject
                        {
                            ["op"] = "replace",
                            ["path"] = "/" + EscapeJsonPointerSegment(kv.Key),
                            ["value"] = JsonNode.Parse(kv.Value.GetRawText())!,
                        }
                    );
                }
            }

            patchArray = new JsonArray();
            foreach (var op in ops)
            {
                patchArray.Add(op);
            }

            return true;
        }
    }

    private static string EscapeJsonPointerSegment(string token)
    {
        return token.Replace("~", "~0", StringComparison.Ordinal).Replace("/", "~1", StringComparison.Ordinal);
    }

    private static bool JsonElementsEqual(JsonElement a, JsonElement b)
    {
        if (a.ValueKind != b.ValueKind)
        {
            return false;
        }

        return a.GetRawText() == b.GetRawText();
    }
}
