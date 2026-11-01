using System.Text.Json;
using System.Text.Json.Serialization;
using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.WebApi.Services.Fights;

/// <summary>SSE event types about fights.</summary>
public static class FightEvents
{
    /// <summary>To each player with pending participants when a fight starts: roll for these.</summary>
    public const string InitiativeRequested = "initiativeRequested";

    /// <summary>
    /// To the owner of participants that no longer wait for a roll - rolled in any of their apps or by the DM, or
    /// removed by the DM - so every app of theirs stops asking for them.
    /// </summary>
    public const string InitiativeSettled = "initiativeSettled";

    /// <summary>To the DM when a fight changed without them (a player rolled): fetch it again.</summary>
    public const string FightUpdated = "fightUpdated";

    /// <summary>To the DM and every asked player when a fight is over.</summary>
    public const string FightEnded = "fightEnded";

    /// <summary>Pre-persistence ask, still sent so older apps prompt their players.</summary>
    public const string LegacyPlayersAreAskedForRolls = "playersAreAskedForRolls";

    /// <summary>Pre-persistence answer, still sent so older DM apps see the rolls.</summary>
    public const string LegacyDmReceivedFightSequenceAnswer = "dmReceivedFightSequenceAnswer";
}

public interface IFightNotifier
{
    /// <summary>
    /// Asks every owner of a pending participant to roll (<see cref="FightEvents.InitiativeRequested"/>). With
    /// <paramref name="includeLegacyAsk"/> also sends the pre-persistence ask to the session's online players.
    /// </summary>
    Task NotifyStartedAsync(FightSnapshot fight, Guid actorUserId, bool includeLegacyAsk, CancellationToken cancellationToken);

    /// <summary>
    /// Tells the owners of <paramref name="settled"/> that these no longer wait for a roll
    /// (<see cref="FightEvents.InitiativeSettled"/>). The actor hears it too: their other apps may still ask.
    /// </summary>
    Task NotifySettledAsync(
        FightSnapshot fight,
        IEnumerable<FightParticipantSnapshot> settled,
        CancellationToken cancellationToken
    );

    /// <summary>Tells the DM and every asked player that the fight is over, except the actor.</summary>
    Task NotifyEndedAsync(FightSnapshot fight, Guid actorUserId, CancellationToken cancellationToken);

    /// <summary>Tells the DM to reload the fight, unless the DM made the change.</summary>
    Task NotifyUpdatedAsync(FightSnapshot fight, Guid actorUserId, CancellationToken cancellationToken);

    /// <summary>Sends the rolls in the pre-persistence format to the DM, if the DM is at the table.</summary>
    Task NotifyLegacyRollsToDmAsync(
        FightSnapshot fight,
        IReadOnlyList<FightParticipantSnapshot> rolled,
        CancellationToken cancellationToken
    );
}

public sealed class FightNotifier : IFightNotifier
{
    private static readonly JsonSerializerOptions SerializerOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Converters = { new JsonStringEnumConverter() },
    };

    private readonly ISseEventHub _sseEventHub;
    private readonly ISessionPresenceService _sessionPresenceService;

    public FightNotifier(ISseEventHub sseEventHub, ISessionPresenceService sessionPresenceService)
    {
        _sseEventHub = sseEventHub;
        _sessionPresenceService = sessionPresenceService;
    }

    public async Task NotifyStartedAsync(
        FightSnapshot fight,
        Guid actorUserId,
        bool includeLegacyAsk,
        CancellationToken cancellationToken
    )
    {
        foreach (var owner in fight.Pending.GroupBy(p => p.OwnerUserId!.Value))
        {
            var payload = Serialize(
                new
                {
                    fightId = fight.Id,
                    campagneId = fight.CampagneId,
                    participants = owner.Select(p => new
                    {
                        participantId = p.Id,
                        characterUuid = p.CharacterUuid,
                        playerCharacterId = p.PlayerCharacterId,
                        name = p.Name,
                        kind = p.Kind,
                    }),
                }
            );
            await _sseEventHub
                .SendToUserAsync(owner.Key, FightEvents.InitiativeRequested, payload, cancellationToken)
                .ConfigureAwait(false);
        }

        if (!includeLegacyAsk)
        {
            return;
        }

        var recipients = _sessionPresenceService
            .GetOnlineParticipants(fight.CampagneId)
            .Where(id => id != actorUserId)
            .ToList();
        if (recipients.Count == 0)
        {
            return;
        }

        var legacyPayload = Serialize(
            new
            {
                fightUuid = fight.Id.ToString(),
                sequence = fight.Pending.Select(p => new
                {
                    characterId = p.CharacterUuid,
                    characterName = p.Name,
                    roll = -1,
                }),
            }
        );
        await _sseEventHub
            .SendToUsersAsync(recipients, FightEvents.LegacyPlayersAreAskedForRolls, legacyPayload, cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task NotifySettledAsync(
        FightSnapshot fight,
        IEnumerable<FightParticipantSnapshot> settled,
        CancellationToken cancellationToken
    )
    {
        foreach (var owner in settled.Where(p => p.OwnerUserId != null).GroupBy(p => p.OwnerUserId!.Value))
        {
            var payload = Serialize(
                new
                {
                    fightId = fight.Id,
                    campagneId = fight.CampagneId,
                    participants = owner.Select(p => new
                    {
                        participantId = p.Id,
                        characterUuid = p.CharacterUuid,
                        roll = p.Roll,
                    }),
                }
            );
            await _sseEventHub
                .SendToUserAsync(owner.Key, FightEvents.InitiativeSettled, payload, cancellationToken)
                .ConfigureAwait(false);
        }
    }

    public Task NotifyEndedAsync(FightSnapshot fight, Guid actorUserId, CancellationToken cancellationToken)
    {
        var recipients = fight
            .Participants.Where(p => p.OwnerUserId != null)
            .Select(p => p.OwnerUserId!.Value)
            .Append(fight.DmUserId)
            .Where(id => id != actorUserId)
            .Distinct()
            .ToList();
        if (recipients.Count == 0)
        {
            return Task.CompletedTask;
        }

        var payload = Serialize(
            new
            {
                fightId = fight.Id,
                campagneId = fight.CampagneId,
                reason = fight.EndReason,
            }
        );
        return _sseEventHub.SendToUsersAsync(recipients, FightEvents.FightEnded, payload, cancellationToken);
    }

    public Task NotifyUpdatedAsync(FightSnapshot fight, Guid actorUserId, CancellationToken cancellationToken)
    {
        if (fight.DmUserId == actorUserId)
        {
            return Task.CompletedTask;
        }

        var payload = Serialize(
            new
            {
                fightId = fight.Id,
                campagneId = fight.CampagneId,
                revision = fight.Revision,
            }
        );
        return _sseEventHub.SendToUserAsync(fight.DmUserId, FightEvents.FightUpdated, payload, cancellationToken);
    }

    public Task NotifyLegacyRollsToDmAsync(
        FightSnapshot fight,
        IReadOnlyList<FightParticipantSnapshot> rolled,
        CancellationToken cancellationToken
    )
    {
        if (rolled.Count == 0 || !_sessionPresenceService.IsOnline(fight.CampagneId, fight.DmUserId))
        {
            return Task.CompletedTask;
        }

        var payload = Serialize(
            new
            {
                fightUuid = fight.Id.ToString(),
                sequence = rolled.Select(p => new
                {
                    characterId = p.CharacterUuid,
                    characterName = p.Name,
                    roll = p.Roll,
                }),
            }
        );
        return _sseEventHub.SendToUserAsync(
            fight.DmUserId,
            FightEvents.LegacyDmReceivedFightSequenceAnswer,
            payload,
            cancellationToken
        );
    }

    private static string Serialize(object payload) => JsonSerializer.Serialize(payload, SerializerOptions);
}
