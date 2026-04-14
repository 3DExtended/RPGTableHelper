using System.Diagnostics.CodeAnalysis;
using System.Text.Json;
using System.Text.Json.Nodes;

using Json.Patch;

namespace RPGTableHelper.WebApi.Services;

/// <summary>
/// Parses protocol v3 JSON envelopes sent from clients (DM/player) and resolves them to a slice JSON string.
/// </summary>
public static class RpgConfigSliceV3UpstreamEnvelope
{
    /// <summary>
    /// Resolves an upstream envelope into canonical slice JSON. For patches, <paramref name="currentRevision"/> must match <c>fromRevision</c>.
    /// </summary>
    public static bool TryResolveSlicePayload(
        string envelopeJson,
        string expectedSlice,
        string? currentJson,
        int currentRevision,
        [NotNullWhen(true)] out string? resolvedJson,
        [NotNullWhen(false)] out string? error
    )
    {
        resolvedJson = null;
        error = null;

        JsonDocument doc;
        try
        {
            doc = JsonDocument.Parse(envelopeJson);
        }
        catch (JsonException ex)
        {
            error = ex.Message;
            return false;
        }

        using (doc)
        {
            var root = doc.RootElement;
            if (root.ValueKind != JsonValueKind.Object)
            {
                error = "Root must be an object.";
                return false;
            }

            if (!root.TryGetProperty("slice", out var sliceEl) || sliceEl.GetString() != expectedSlice)
            {
                error = "slice mismatch.";
                return false;
            }

            if (!root.TryGetProperty("kind", out var kindEl))
            {
                error = "Missing kind.";
                return false;
            }

            var kind = kindEl.GetString();
            if (kind == "full")
            {
                if (!root.TryGetProperty("body", out var body))
                {
                    error = "full requires body.";
                    return false;
                }

                resolvedJson = JsonSerializer.Serialize(body, RpgConfigSliceV3EnvelopeBuilder.SerializerOptions);
                return true;
            }

            if (kind != "patch")
            {
                error = "Unknown kind.";
                return false;
            }

            if (!root.TryGetProperty("fromRevision", out var fromRevEl) || fromRevEl.GetInt32() != currentRevision)
            {
                error = "fromRevision mismatch.";
                return false;
            }

            if (!root.TryGetProperty("patch", out var patchEl))
            {
                error = "patch requires patch array.";
                return false;
            }

            JsonPatch? patch;
            try
            {
                patch = JsonSerializer.Deserialize<JsonPatch>(patchEl.GetRawText());
            }
            catch (JsonException ex)
            {
                error = ex.Message;
                return false;
            }

            if (patch is null)
            {
                error = "patch is null.";
                return false;
            }

            var baseJson = string.IsNullOrWhiteSpace(currentJson) ? "{}" : currentJson;
            JsonNode baseNode;
            try
            {
                baseNode = JsonNode.Parse(baseJson)!;
            }
            catch (JsonException ex)
            {
                error = ex.Message;
                return false;
            }

            var patchResult = patch.Apply(baseNode);
            if (!patchResult.IsSuccess)
            {
                error = patchResult.Error ?? "patch apply failed.";
                return false;
            }

            resolvedJson = JsonSerializer.Serialize(patchResult.Result, RpgConfigSliceV3EnvelopeBuilder.SerializerOptions);
            return true;
        }
    }
}
