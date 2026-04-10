namespace RPGTableHelper.Api.Tests.SignalRControllers;

/// <summary>
/// Builds JSON-shaped strings of roughly a given size (for SignalR / SQLite round-trip tests
/// ahead of splitting campagne vs character DTOs and hub payloads).
/// </summary>
internal static class SignalRTestPayloadBuilder
{
    /// <summary>Returns a JSON object string whose UTF-16 length is at least <paramref name="minChars"/>.</summary>
    public static string JsonObjectWithMinimumLength(int minChars)
    {
        // {"b":"<repeat>"} — ASCII so byte size tracks char size for common environments.
        const string prefix = "{\"b\":\"";
        const string suffix = "\"}";
        var inner = Math.Max(0, minChars - prefix.Length - suffix.Length);
        return prefix + new string('x', inner) + suffix;
    }

    /// <summary>Includes a few non-ASCII codepoints to catch encoding issues.</summary>
    public static string JsonWithUnicodeEscapes()
    {
        return """{"label":"campagne-üñiçôdè","items":["★","🎲"]}""";
    }
}
