using System.Text.Json;

namespace RPGTableHelper.WebApi.Services;

public static class RpgConfigColdHotSlicer
{
    public const int SchemaVersion = 1;

    // Cold: big/rarely changing parts.
    private static readonly HashSet<string> ColdKeys =
    [
        "allItems",
        "placesOfFindings",
        "itemCategories",
        "characterStatTabsDefinition",
        "craftingRecipes",
        "currencyDefinition",
    ];

    // Hot: small/frequently changing parts.
    private static readonly HashSet<string> HotKeys = ["rpgName"];

    public sealed record Slices(string coldJson, string hotJson, int schemaVersion)
    {
        public string ColdJson { get; } = coldJson;
        public string HotJson { get; } = hotJson;
        public int SchemaVersion { get; } = schemaVersion;
    }

    public static Slices SliceFromLegacyFull(string legacyFullJson)
    {
        if (string.IsNullOrWhiteSpace(legacyFullJson))
        {
            return new Slices("{}", "{}", SchemaVersion);
        }

        try
        {
            using var doc = JsonDocument.Parse(legacyFullJson);
            if (doc.RootElement.ValueKind != JsonValueKind.Object)
            {
                return new Slices("{}", "{}", SchemaVersion);
            }

            var cold = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
            var hot = new Dictionary<string, JsonElement>(StringComparer.Ordinal);

            foreach (var prop in doc.RootElement.EnumerateObject())
            {
                if (ColdKeys.Contains(prop.Name))
                {
                    cold[prop.Name] = prop.Value.Clone();
                }
                else if (HotKeys.Contains(prop.Name))
                {
                    hot[prop.Name] = prop.Value.Clone();
                }
                else
                {
                    // Unknown/new keys: keep them in hot so we don't drop data on merge.
                    hot[prop.Name] = prop.Value.Clone();
                }
            }

            return new Slices(
                JsonSerializer.Serialize(cold),
                JsonSerializer.Serialize(hot),
                SchemaVersion
            );
        }
        catch (JsonException)
        {
            // Legacy test payloads (and potentially corrupt DB rows) may not be JSON.
            // Do not throw: callers can still persist/broadcast the raw legacy string.
            return new Slices("{}", "{}", SchemaVersion);
        }

        // unreachable
    }

    public static string MergeToLegacyFull(string? coldJson, string? hotJson)
    {
        var merged = new Dictionary<string, JsonElement>(StringComparer.Ordinal);

        void MergeObjectInto(string? json)
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return;
            }

            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind != JsonValueKind.Object)
            {
                return;
            }

            foreach (var prop in doc.RootElement.EnumerateObject())
            {
                merged[prop.Name] = prop.Value.Clone();
            }
        }

        // Hot overwrites cold on conflict.
        MergeObjectInto(coldJson);
        MergeObjectInto(hotJson);

        return JsonSerializer.Serialize(merged);
    }
}
