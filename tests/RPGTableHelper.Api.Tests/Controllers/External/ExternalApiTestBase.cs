using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

using FluentAssertions;

using Microsoft.AspNetCore.Mvc.Testing;

using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Controllers.External;

/// <summary>
/// A campaign table for player API tests: the DM is the logged-in <see cref="ControllerTestBase.Client"/>, players
/// have a character with hit points (and optionally a companion), and the campaign defines those stats.
/// </summary>
public abstract class ExternalApiTestBase : ControllerTestBase
{
    protected const string V1 = "/api/external/v1";

    protected const string HpStat = "hp-stat";

    protected const string BioStat = "bio-stat";

    protected static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
    };

    protected ExternalApiTestBase(WebApplicationFactory<Program> factory)
        : base(factory) { }

    protected static string HpValue(int value, int maxValue) =>
        new JsonObject { ["value"] = value, ["maxValue"] = maxValue }.ToJsonString();

    protected static async Task<string> ReadUntilEventAsync(StreamReader reader, string eventType)
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(5));
        while (true)
        {
            var line = await reader.ReadLineAsync(timeout.Token);
            line.Should().NotBeNull("the event stream should stay open");
            if (line == $"event: {eventType}")
            {
                var data = await reader.ReadLineAsync(timeout.Token);
                return data!["data: ".Length..];
            }
        }
    }

    /// <summary>The <c>error</c> code of a player API error body.</summary>
    protected static async Task<string?> ReadErrorCodeAsync(HttpResponseMessage response)
    {
        var body = await response.Content.ReadAsStringAsync();
        return JsonNode.Parse(body)?["error"]?.GetValue<string>();
    }

    protected static StringContent Json(object body) =>
        new(JsonSerializer.Serialize(body, JsonOptions), Encoding.UTF8, "application/json");

    protected async Task<(User Dm, Campagne Campagne)> CreateTableAsync()
    {
        var dm = await ConfigureLoggedInUser();
        var campagne = await RpgDbContextHelpers.CreateCampagneInDb(
            ContextFactory!,
            Mapper!,
            dm,
            joinCode: Guid.NewGuid().ToString()[..8]
        );

        var config = new JsonObject
        {
            ["characterStatTabsDefinition"] = new JsonArray(
                new JsonObject
                {
                    ["uuid"] = "tab-1",
                    ["tabName"] = "Main",
                    ["statsInTab"] = new JsonArray(
                        new JsonObject
                        {
                            ["statUuid"] = HpStat,
                            ["name"] = "Hit points",
                            ["valueType"] = "intWithMaxValue",
                        },
                        new JsonObject
                        {
                            ["statUuid"] = BioStat,
                            ["name"] = "Biography",
                            ["valueType"] = "multiLineText",
                        }
                    ),
                }
            ),
        };
        using (var context = ContextFactory!.CreateDbContext())
        {
            var entity = context.Campagnes.Single(c => c.Id == campagne.Id.Value);
            entity.RpgConfiguration = config.ToJsonString();
            entity.RpgConfigurationMergedRevision = 3;
            await context.SaveChangesAsync();
        }

        return (dm, campagne);
    }

    /// <summary>A campaign the logged-in DM and the test players are not part of.</summary>
    protected async Task<Campagne> CreateForeignCampaignAsync()
    {
        var otherDm = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory!,
            Mapper!,
            usernameOverride: "OtherDm-" + Guid.NewGuid().ToString()[..6]
        );
        return await RpgDbContextHelpers.CreateCampagneInDb(
            ContextFactory!,
            Mapper!,
            otherDm,
            joinCode: Guid.NewGuid().ToString()[..8]
        );
    }

    protected async Task<TablePlayer> AddPlayerAsync(Campagne campagne, string characterName, string? companionUuid = null)
    {
        var user = await RpgDbContextHelpers.CreateUserInDb(
            ContextFactory!,
            Mapper!,
            usernameOverride: characterName + "-" + Guid.NewGuid().ToString()[..6]
        );
        var uuid = Guid.NewGuid().ToString();
        var sheet = new JsonObject
        {
            ["uuid"] = uuid,
            ["characterName"] = characterName,
            ["characterStats"] = new JsonArray(
                Stat(BioStat, new JsonObject { ["value"] = "Brave" }.ToJsonString()),
                Stat(HpStat, HpValue(10, 20))
            ),
            ["inventory"] = new JsonArray(),
            ["moneyInBaseType"] = 0,
            ["companionCharacters"] = companionUuid == null
                ? new JsonArray()
                : new JsonArray(
                    new JsonObject
                    {
                        ["uuid"] = companionUuid,
                        ["characterName"] = "Wolf",
                        ["characterStats"] = new JsonArray(Stat(HpStat, HpValue(5, 8))),
                    }
                ),
        };

        var character = new PlayerCharacterEntity
        {
            Id = Guid.NewGuid(),
            CharacterName = characterName,
            PlayerUserId = user.Id.Value,
            CampagneId = campagne.Id.Value,
            RpgCharacterConfiguration = sheet.ToJsonString(),
            RpgCharacterConfigurationRevision = 1,
        };
        using (var context = ContextFactory!.CreateDbContext())
        {
            await context.PlayerCharacters.AddAsync(character);
            await context.SaveChangesAsync();
        }

        var appClient = Factory.CreateClient();
        appClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", CreateJwtForUser(user));
        return new TablePlayer(user, appClient, character.Id, uuid);
    }

    protected async Task<JsonObject> LoadStoredSheetAsync(Guid characterId)
    {
        using var context = ContextFactory!.CreateDbContext();
        var character = context.PlayerCharacters.Single(c => c.Id == characterId);
        return JsonNode.Parse(character.RpgCharacterConfiguration!)!.AsObject();
    }

    private static JsonObject Stat(string statUuid, string serializedValue) =>
        new() { ["statUuid"] = statUuid, ["serializedValue"] = serializedValue };

    /// <summary>A player at the table with their app client (JWT) and character.</summary>
    protected sealed class TablePlayer
    {
        public TablePlayer(User user, HttpClient appClient, Guid characterId, string uuid)
        {
            User = user;
            AppClient = appClient;
            CharacterId = characterId;
            Uuid = uuid;
        }

        public User User { get; }

        /// <summary>The player's Questkeeper app, logged in with a JWT.</summary>
        public HttpClient AppClient { get; }

        public Guid CharacterId { get; }

        /// <summary>The <c>uuid</c> inside the character's sheet.</summary>
        public string Uuid { get; }
    }
}
