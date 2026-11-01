using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.WebApi.Services.Sse;

/// <summary>
/// The events an API key's <c>/events</c> stream receives, each with the scope it needs. It is an allow-list:
/// whatever is not listed - join requests, the DM's fight updates, the app's legacy fight events and any event
/// added later - never reaches an API key. <c>hello</c> is written by the stream itself and always arrives.
/// </summary>
public static class ExternalEventCatalog
{
    public static readonly IReadOnlyDictionary<string, string> RequiredScopes = new Dictionary<string, string>(
        StringComparer.Ordinal
    )
    {
        ["participantOnline"] = ApiKeyScopes.Events,
        ["participantOffline"] = ApiKeyScopes.Events,
        ["characterConfigChanged"] = ApiKeyScopes.CharactersRead,
        ["itemsGranted"] = ApiKeyScopes.CharactersRead,
        ["campagneConfigChanged"] = ApiKeyScopes.CampaignsRead,
        ["noteAccessChanged"] = ApiKeyScopes.NotesRead,
        [FightEvents.InitiativeRequested] = ApiKeyScopes.FightsPlay,
        [FightEvents.InitiativeSettled] = ApiKeyScopes.FightsPlay,
        [FightEvents.FightEnded] = ApiKeyScopes.FightsPlay,
    };

    /// <summary>True if a stream opened with a key holding <paramref name="scopes"/> gets <paramref name="eventType"/>.</summary>
    public static bool IsDelivered(string eventType, IReadOnlyCollection<string> scopes) =>
        RequiredScopes.TryGetValue(eventType, out var scope) && scopes.Contains(scope);
}
