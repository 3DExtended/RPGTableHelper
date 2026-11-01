using System.Text.Json;
using System.Text.Json.Nodes;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;

namespace RPGTableHelper.WebApi.Services.Fights;

/// <summary>A player character of a campagne, with its stored configuration.</summary>
public sealed record CampagneCharacter
{
    public CampagneCharacter(
        Guid playerCharacterId,
        Guid ownerUserId,
        string characterName,
        string? configJson
    )
    {
        PlayerCharacterId = playerCharacterId;
        OwnerUserId = ownerUserId;
        CharacterName = characterName;
        ConfigJson = configJson;
    }

    public Guid PlayerCharacterId { get; }

    public Guid OwnerUserId { get; }

    public string CharacterName { get; }

    public string? ConfigJson { get; }
}

/// <summary>Someone who can be asked for initiative: a character or one of its companions.</summary>
public sealed record FightCombatant
{
    public FightCombatant(
        string characterUuid,
        Guid playerCharacterId,
        Guid ownerUserId,
        string name,
        FightParticipantKind kind
    )
    {
        CharacterUuid = characterUuid;
        PlayerCharacterId = playerCharacterId;
        OwnerUserId = ownerUserId;
        Name = name;
        Kind = kind;
    }

    public string CharacterUuid { get; }

    public Guid PlayerCharacterId { get; }

    public Guid OwnerUserId { get; }

    public string Name { get; }

    public FightParticipantKind Kind { get; }
}

/// <summary>
/// Finds the characters and companions of a campagne by the <c>uuid</c>s inside their configurations, which is
/// how clients name fight participants.
/// </summary>
public static class FightCharacterResolver
{
    // Alternate forms used to live in their own list; newer configurations keep them with the companions.
    private static readonly string[] CompanionLists = { "companionCharacters", "alternateForms" };

    public static IReadOnlyList<FightCombatant> ListCombatants(IEnumerable<CampagneCharacter> characters)
    {
        var result = new List<FightCombatant>();
        var seen = new HashSet<string>(StringComparer.Ordinal);

        foreach (var character in characters)
        {
            var root = TryParse(character.ConfigJson);
            if (root == null)
            {
                continue;
            }

            var uuid = ReadString(root, "uuid");
            if (!string.IsNullOrWhiteSpace(uuid) && seen.Add(uuid))
            {
                result.Add(
                    new FightCombatant(
                        uuid,
                        character.PlayerCharacterId,
                        character.OwnerUserId,
                        ReadString(root, "characterName") ?? character.CharacterName,
                        FightParticipantKind.Character
                    )
                );
            }

            foreach (var listName in CompanionLists)
            {
                if (root[listName] is not JsonArray companions)
                {
                    continue;
                }

                foreach (var companion in companions.OfType<JsonObject>())
                {
                    var companionUuid = ReadString(companion, "uuid");
                    if (string.IsNullOrWhiteSpace(companionUuid) || !seen.Add(companionUuid))
                    {
                        continue;
                    }

                    result.Add(
                        new FightCombatant(
                            companionUuid,
                            character.PlayerCharacterId,
                            character.OwnerUserId,
                            ReadString(companion, "characterName") ?? character.CharacterName,
                            FightParticipantKind.Companion
                        )
                    );
                }
            }
        }

        return result;
    }

    private static JsonObject? TryParse(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return null;
        }

        try
        {
            return JsonNode.Parse(json) as JsonObject;
        }
        catch (JsonException)
        {
            return null;
        }
    }

    private static string? ReadString(JsonObject node, string property) =>
        node[property] is JsonValue value && value.TryGetValue<string>(out var text) ? text : null;
}
