using System.Text;
using System.Text.Json;

namespace RPGTableHelper.Api.Tests.TestData;

/// <summary>
/// Resolves committed <c>liveBackups/*.json</c> files copied to the test output directory.
/// </summary>
internal static class LiveBackupTestPaths
{
    /// <summary>Production campaign RPG configuration JSON backup (~300KB+) with cold keys.</summary>
    public const string CampaignRpgConfiguration =
        "0d5f92c4-7dae-4763-b1e3-be600f3e3913-20260318-rpgbackup.json";

    /// <summary>All JSON files shipped for slicer regression tests (campaign + character backups).</summary>
    public static readonly IReadOnlyList<string> AllBackupFileNames =
    [
        CampaignRpgConfiguration,
        "Faugar-1a75aa43-4283-4f09-b08a-1f0c73e7e3a1-20260407-2004-rpgbackup.json",
        "Kaedrin Valeskaar-b1d2c597-c013-4ff0-9d2c-119fbd656154-20260318-2025-rpgbackup.json",
        "Kardan-098ec623-2e9d-4ab6-b7f2-572a92865eda-20260321-1930-rpgbackup.json",
        "Shava -e03d1aa9-1227-46d0-a0e1-8cda1d5f6ab2-20260318-2028-rpgbackup.json",
        "Thamior-a7a49292-fdea-4e72-8be0-2fce30afcdb6-20260318-2059-rpgbackup.json",
    ];

    public static string GetPath(string fileName) => Path.Combine(LiveBackupsDir, fileName);

    public static string ReadAllText(string fileName) =>
        File.ReadAllText(GetPath(fileName), Encoding.UTF8);

    /// <summary>Stable JSON text for equality checks (System.Text.Json round-trip).</summary>
    public static string CanonJson(string json)
    {
        using var doc = JsonDocument.Parse(json);
        return JsonSerializer.Serialize(doc.RootElement);
    }

    /// <summary>
    /// Structural equality (ignores property order at each object), for comparing slicer merge output to on-disk JSON.
    /// </summary>
    public static bool JsonDeepEquals(string? a, string? b)
    {
        if (ReferenceEquals(a, b))
        {
            return true;
        }

        if (a is null || b is null)
        {
            return false;
        }

        using var da = JsonDocument.Parse(a);
        using var db = JsonDocument.Parse(b);
        return JsonElementDeepEquals(da.RootElement, db.RootElement);
    }

    private static bool JsonElementDeepEquals(JsonElement a, JsonElement b)
    {
        if (a.ValueKind != b.ValueKind)
        {
            return false;
        }

        switch (a.ValueKind)
        {
            case JsonValueKind.Object:
                {
                    var dictA = a.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);
                    var dictB = b.EnumerateObject().ToDictionary(p => p.Name, p => p.Value, StringComparer.Ordinal);
                    if (dictA.Count != dictB.Count)
                    {
                        return false;
                    }

                    foreach (var kv in dictA)
                    {
                        if (!dictB.TryGetValue(kv.Key, out var vb))
                        {
                            return false;
                        }

                        if (!JsonElementDeepEquals(kv.Value, vb))
                        {
                            return false;
                        }
                    }

                    return true;
                }

            case JsonValueKind.Array:
                if (a.GetArrayLength() != b.GetArrayLength())
                {
                    return false;
                }

                for (var i = 0; i < a.GetArrayLength(); i++)
                {
                    if (!JsonElementDeepEquals(a[i], b[i]))
                    {
                        return false;
                    }
                }

                return true;
            case JsonValueKind.String:
                return a.GetString() == b.GetString();
            case JsonValueKind.Number:
            case JsonValueKind.True:
            case JsonValueKind.False:
            case JsonValueKind.Null:
                return a.GetRawText() == b.GetRawText();
            default:
                return a.GetRawText() == b.GetRawText();
        }
    }

    private static readonly string LiveBackupsDir = Path.Combine(AppContext.BaseDirectory, "liveBackups");
}
