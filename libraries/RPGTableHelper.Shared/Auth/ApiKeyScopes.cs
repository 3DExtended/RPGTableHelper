namespace RPGTableHelper.Shared.Auth
{
    /// <summary>
    /// Permissions a player grants an API key. A key only reaches the external player API and the event
    /// stream; every endpoint there requires one of these scopes. Persisted space-separated on the key.
    /// </summary>
    public static class ApiKeyScopes
    {
        public const string CampaignsRead = "campaigns:read";
        public const string CharactersRead = "characters:read";
        public const string CharactersWrite = "characters:write";
        public const string NotesRead = "notes:read";
        public const string NotesWrite = "notes:write";
        public const string FightsPlay = "fights:play";
        public const string Events = "events";

        /// <summary>All known scopes, in display order.</summary>
        public static readonly IReadOnlyList<string> All = new[]
        {
            CampaignsRead,
            CharactersRead,
            CharactersWrite,
            NotesRead,
            NotesWrite,
            FightsPlay,
            Events,
        };

        /// <summary>
        /// Scopes of keys created before scopes existed: exactly what the read-only external API offered.
        /// </summary>
        public static readonly IReadOnlyList<string> LegacyDefault = new[] { CampaignsRead, CharactersRead, NotesRead };

        public static bool IsKnown(string scope) => All.Contains(scope);

        /// <summary>Serializes scopes for storage: known scopes only, deduplicated, in display order.</summary>
        public static string Serialize(IEnumerable<string>? scopes) =>
            string.Join(' ', Normalize(scopes));

        /// <summary>Parses stored scopes, dropping unknown entries.</summary>
        public static List<string> Parse(string? serialized) =>
            Normalize((serialized ?? string.Empty).Split(' ', StringSplitOptions.RemoveEmptyEntries));

        private static List<string> Normalize(IEnumerable<string>? scopes) =>
            All.Where(known => scopes?.Contains(known) == true).ToList();
    }
}
