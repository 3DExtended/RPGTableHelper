using System.Text.Json;
using System.Text.Json.Nodes;

namespace RPGTableHelper.WebApi.Services.Characters;

/// <summary>
/// Checks that a character sheet (the player character configuration JSON) still has the shape the app reads:
/// the fields it needs, and stat values that fit the stat types the campagne configuration defines. Every
/// problem is a stable, readable message, so a write can be rejected only for problems it introduced
/// (see <see cref="FindNewProblems"/>).
/// </summary>
public static class CharacterSheetValidator
{
    /// <summary>The problems in <paramref name="afterJson"/> that <paramref name="beforeJson"/> did not have.</summary>
    public static IReadOnlyList<string> FindNewProblems(string? beforeJson, string afterJson, string? campagneConfigJson)
    {
        var statTypes = ReadStatTypes(campagneConfigJson);
        var before = Validate(beforeJson, statTypes).ToHashSet(StringComparer.Ordinal);
        var problems = Validate(afterJson, statTypes).Where(p => !before.Contains(p)).ToList();

        var uuidBefore = ReadUuid(beforeJson);
        var uuidAfter = ReadUuid(afterJson);
        if (!string.IsNullOrEmpty(uuidBefore) && uuidAfter != null && uuidAfter != uuidBefore)
        {
            problems.Add("/uuid: must not change; fights and other players refer to the character by it.");
        }

        return problems;
    }

    /// <summary>Every problem of the sheet, independent of the order of its stats.</summary>
    public static IReadOnlyList<string> Validate(string? sheetJson, IReadOnlyDictionary<string, string> statTypes)
    {
        var problems = new List<string>();
        var root = TryParse(sheetJson);
        if (root is not JsonObject sheet)
        {
            problems.Add("The sheet must be a JSON object.");
            return problems;
        }

        RequireString(sheet, "uuid", string.Empty, problems, allowEmpty: false);
        RequireString(sheet, "characterName", string.Empty, problems, allowEmpty: true);
        CheckStats(sheet, "characterStats", string.Empty, statTypes, problems, required: true);

        if (sheet.TryGetPropertyValue("inventory", out var inventory) && inventory != null)
        {
            if (inventory is not JsonArray items)
            {
                problems.Add("/inventory: must be an array.");
            }
            else
            {
                foreach (var item in items)
                {
                    if (item is not JsonObject pair || ReadString(pair, "itemUuid") == null || !IsInteger(pair["amount"]))
                    {
                        problems.Add("/inventory: every entry needs an itemUuid (string) and an amount (integer).");
                        break;
                    }
                }
            }
        }

        if (sheet.TryGetPropertyValue("moneyInBaseType", out var money) && money != null && !IsInteger(money))
        {
            problems.Add("/moneyInBaseType: must be an integer.");
        }

        foreach (var listName in new[] { "companionCharacters", "alternateForms" })
        {
            if (!sheet.TryGetPropertyValue(listName, out var list) || list == null)
            {
                continue;
            }

            if (list is not JsonArray characters)
            {
                problems.Add($"/{listName}: must be an array.");
                continue;
            }

            foreach (var character in characters)
            {
                if (character is not JsonObject companion)
                {
                    problems.Add($"/{listName}: every entry must be an object.");
                    continue;
                }

                var uuid = ReadString(companion, "uuid");
                var path = $"/{listName}[uuid={uuid}]";
                if (string.IsNullOrEmpty(uuid))
                {
                    problems.Add($"/{listName}: every entry needs a uuid.");
                    continue;
                }

                RequireString(companion, "characterName", path, problems, allowEmpty: true);
                CheckStats(companion, "characterStats", path, statTypes, problems, required: true);
            }
        }

        return problems;
    }

    /// <summary>Stat uuid → value type name (e.g. <c>intWithMaxValue</c>) from a campagne configuration.</summary>
    public static IReadOnlyDictionary<string, string> ReadStatTypes(string? campagneConfigJson)
    {
        var result = new Dictionary<string, string>(StringComparer.Ordinal);
        if (TryParse(campagneConfigJson) is not JsonObject config || config["characterStatTabsDefinition"] is not JsonArray tabs)
        {
            return result;
        }

        foreach (var tab in tabs.OfType<JsonObject>())
        {
            if (tab["statsInTab"] is not JsonArray stats)
            {
                continue;
            }

            foreach (var stat in stats.OfType<JsonObject>())
            {
                var statUuid = ReadString(stat, "statUuid");
                var valueType = stat["valueType"] is JsonValue v ? v.ToString() : null;
                if (!string.IsNullOrEmpty(statUuid) && !string.IsNullOrEmpty(valueType))
                {
                    result[statUuid] = valueType;
                }
            }
        }

        return result;
    }

    private static void CheckStats(
        JsonObject owner,
        string property,
        string path,
        IReadOnlyDictionary<string, string> statTypes,
        List<string> problems,
        bool required
    )
    {
        if (!owner.TryGetPropertyValue(property, out var node) || node == null)
        {
            if (required)
            {
                problems.Add($"{path}/{property}: is required.");
            }

            return;
        }

        if (node is not JsonArray stats)
        {
            problems.Add($"{path}/{property}: must be an array.");
            return;
        }

        foreach (var entry in stats)
        {
            if (entry is not JsonObject stat)
            {
                problems.Add($"{path}/{property}: every entry must be an object.");
                continue;
            }

            var statUuid = ReadString(stat, "statUuid");
            if (string.IsNullOrEmpty(statUuid))
            {
                problems.Add($"{path}/{property}: every entry needs a statUuid.");
                continue;
            }

            var statPath = $"{path}/{property}[statUuid={statUuid}]";
            var serialized = ReadString(stat, "serializedValue");
            if (serialized == null)
            {
                problems.Add($"{statPath}/serializedValue: must be a string holding JSON.");
                continue;
            }

            if (TryParse(serialized) is not JsonObject value)
            {
                problems.Add($"{statPath}/serializedValue: must hold a JSON object.");
                continue;
            }

            if (statTypes.Count == 0)
            {
                continue;
            }

            if (!statTypes.TryGetValue(statUuid, out var valueType))
            {
                problems.Add($"{statPath}: the campagne has no stat with this uuid.");
                continue;
            }

            var problem = CheckValue(valueType, value);
            if (problem != null)
            {
                problems.Add($"{statPath}/serializedValue: {problem}");
            }
        }
    }

    /// <summary>Checks a stat value against its type; see <c>CharacterStatValueType</c> in the app.</summary>
    private static string? CheckValue(string valueType, JsonObject value) =>
        valueType switch
        {
            "multiLineText" or "singleLineText" => IsStringOrAbsent(value["value"])
                ? null
                : "\"value\" must be a string.",
            "int" => IsInteger(value["value"]) ? null : "\"value\" must be an integer.",
            "intWithMaxValue" => IsInteger(value["value"]) && IsInteger(value["maxValue"])
                ? null
                : "\"value\" and \"maxValue\" must be integers.",
            "intWithCalculatedValue" => IsInteger(value["value"]) && IsIntegerOrAbsent(value["otherValue"])
                ? null
                : "\"value\" (and \"otherValue\" if set) must be integers.",
            "multiselect" => value["values"] is JsonArray selected && selected.All(IsString)
                ? null
                : "\"values\" must be an array of option uuids.",
            "singleImage" => IsStringOrAbsent(value["imageUrl"]) && IsStringOrAbsent(value["value"])
                ? null
                : "\"imageUrl\" and \"value\" must be strings.",
            "listOfIntWithCalculatedValues" or "listOfIntsWithIcons" => EntriesAre(
                value,
                entry => IsInteger(entry["value"]) && IsIntegerOrAbsent(entry["otherValue"])
            )
                ? null
                : "\"values\" must be an array of { uuid, value (integer) }.",
            "characterNameWithLevelAndAdditionalDetails" => IsIntegerOrAbsent(value["level"])
                && EntriesAre(value, entry => IsStringOrAbsent(entry["value"]))
                ? null
                : "\"level\" must be an integer and \"values\" an array of { uuid, value (string) }.",
            "companionSelector" => EntriesAre(value, _ => true) ? null : "\"values\" must be an array of { uuid }.",
            _ => null,
        };

    private static bool EntriesAre(JsonObject value, Func<JsonObject, bool> isValid) =>
        value["values"] is JsonArray entries
        && entries.All(e => e is JsonObject entry && IsString(entry["uuid"]) && isValid(entry));

    private static void RequireString(JsonObject owner, string property, string path, List<string> problems, bool allowEmpty)
    {
        var text = ReadString(owner, property);
        if (text == null || (!allowEmpty && text.Length == 0))
        {
            problems.Add($"{path}/{property}: must be a {(allowEmpty ? string.Empty : "non-empty ")}string.");
        }
    }

    private static string? ReadUuid(string? sheetJson) =>
        TryParse(sheetJson) is JsonObject sheet ? ReadString(sheet, "uuid") : null;

    private static string? ReadString(JsonObject owner, string property) =>
        owner[property] is JsonValue value && value.TryGetValue<string>(out var text) ? text : null;

    private static bool IsString(JsonNode? node) => node is JsonValue value && value.TryGetValue<string>(out _);

    private static bool IsStringOrAbsent(JsonNode? node) => node == null || IsString(node);

    private static bool IsInteger(JsonNode? node) =>
        node is JsonValue value
        && value.GetValueKind() == JsonValueKind.Number
        && value.TryGetValue<decimal>(out var number)
        && number == decimal.Truncate(number);

    private static bool IsIntegerOrAbsent(JsonNode? node) => node == null || IsInteger(node);

    private static JsonNode? TryParse(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return null;
        }

        try
        {
            return JsonNode.Parse(json);
        }
        catch (JsonException)
        {
            return null;
        }
    }
}
