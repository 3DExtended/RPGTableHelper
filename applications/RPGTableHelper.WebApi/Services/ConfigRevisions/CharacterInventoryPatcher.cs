using System.Text.Json.Nodes;

using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.WebApi.Services.ConfigRevisions;

/// <summary>
/// Additively merges DM item grants (sse-06) into the <c>inventory</c> array of a character config JSON
/// document, mirroring the Flutter client's <c>_grantItemsInternal</c> semantics: existing entries for the
/// same <c>itemUuid</c> have their amount increased (clamped at a minimum of 0), otherwise a new entry is
/// added (unless the granted amount is not positive).
/// </summary>
public static class CharacterInventoryPatcher
{
    public static string ApplyGrants(string? configJson, IEnumerable<GrantedItemDto> grants)
    {
        var root = (JsonNode.Parse(string.IsNullOrWhiteSpace(configJson) ? "{}" : configJson) as JsonObject) ?? new JsonObject();

        if (root["inventory"] is not JsonArray inventory)
        {
            inventory = new JsonArray();
            root["inventory"] = inventory;
        }

        foreach (var grant in grants)
        {
            var existing = inventory
                .OfType<JsonObject>()
                .FirstOrDefault(entry => string.Equals(entry["itemUuid"]?.GetValue<string>(), grant.ItemUuid, StringComparison.Ordinal));

            if (existing != null)
            {
                var currentAmount = existing["amount"]?.GetValue<int>() ?? 0;
                existing["amount"] = Math.Max(currentAmount + grant.Amount, 0);
            }
            else if (grant.Amount > 0)
            {
                inventory.Add(new JsonObject { ["itemUuid"] = grant.ItemUuid, ["amount"] = grant.Amount });
            }
        }

        return root.ToJsonString(ConfigDocumentPatcher.SerializerOptions);
    }
}
