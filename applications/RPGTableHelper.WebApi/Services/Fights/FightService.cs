using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Fights;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services.Fights;

/// <summary>
/// Reads and changes the persisted fights of a campagne. Checks who may do what (DM vs. owner of a
/// participant), keeps the initiative order, and ends fights nobody touched for <see cref="InactivityTimeout"/>.
/// Callers send the SSE notifications (<see cref="IFightNotifier"/>) from the returned result.
/// </summary>
public interface IFightService
{
    Task<FightAccess> GetAccessAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken);

    /// <summary>The open fight of the campagne, or null.</summary>
    Task<FightSnapshot?> GetOpenFightAsync(Guid campagneId, CancellationToken cancellationToken);

    /// <summary>
    /// DM starts a fight and ends the open one, if any. Characters and companions start pending; enemies are
    /// placed by their roll. With <paramref name="skipUnknownParticipants"/> unknown characters are dropped
    /// instead of failing the request (used by the pre-persistence endpoint).
    /// </summary>
    Task<FightOperationResult> StartAsync(
        Guid campagneId,
        Guid actorUserId,
        Guid? requestedFightId,
        IReadOnlyList<FightParticipantRequest> participants,
        IReadOnlyList<FightEnemyRequest> enemies,
        bool skipUnknownParticipants,
        CancellationToken cancellationToken
    );

    /// <summary>
    /// Records rolls for pending participants the actor owns (the DM may roll for anyone). With
    /// <paramref name="skipInvalidRolls"/> rolls that do not apply are ignored instead of failing.
    /// </summary>
    Task<FightOperationResult> SubmitRollsAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<FightRollRequest> rolls,
        bool skipInvalidRolls,
        CancellationToken cancellationToken
    );

    Task<FightOperationResult> AddEnemiesAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<FightEnemyRequest> enemies,
        CancellationToken cancellationToken
    );

    /// <summary>DM sets the initiative order. <paramref name="participantIds"/> must list every participant with a roll.</summary>
    Task<FightOperationResult> ReorderAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<Guid> participantIds,
        CancellationToken cancellationToken
    );

    /// <summary>DM removes a participant; a pending one is no longer asked to roll.</summary>
    Task<FightOperationResult> RemoveParticipantAsync(
        Guid fightId,
        Guid actorUserId,
        Guid participantId,
        CancellationToken cancellationToken
    );

    /// <summary>DM ends the fight. Ending a fight that is already over changes nothing.</summary>
    Task<FightOperationResult> EndAsync(Guid fightId, Guid actorUserId, CancellationToken cancellationToken);
}

public sealed class FightService : IFightService
{
    public const int MinRoll = -1000;
    public const int MaxRoll = 1000;
    public const int MaxNameLength = 200;

    /// <summary>An open fight without any change for this long counts as over.</summary>
    public static readonly TimeSpan InactivityTimeout = TimeSpan.FromHours(12);

    // Fights are small and rarely written; one lock keeps concurrent rolls from losing positions.
    private readonly SemaphoreSlim _writeLock = new(1, 1);
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;
    private readonly ISystemClock _systemClock;

    public FightService(IDbContextFactory<RpgDbContext> contextFactory, ISystemClock systemClock)
    {
        _contextFactory = contextFactory;
        _systemClock = systemClock;
    }

    public async Task<FightAccess> GetAccessAsync(Guid campagneId, Guid userId, CancellationToken cancellationToken)
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
        var dmUserId = await GetDmUserIdAsync(context, campagneId, cancellationToken).ConfigureAwait(false);
        if (dmUserId == null)
        {
            return FightAccess.None;
        }

        if (dmUserId == userId)
        {
            return FightAccess.Dm;
        }

        var hasCharacter = await context
            .PlayerCharacters.AnyAsync(pc => pc.CampagneId == campagneId && pc.PlayerUserId == userId, cancellationToken)
            .ConfigureAwait(false);
        return hasCharacter ? FightAccess.Player : FightAccess.None;
    }

    public async Task<FightSnapshot?> GetOpenFightAsync(Guid campagneId, CancellationToken cancellationToken)
    {
        await _writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
            var dmUserId = await GetDmUserIdAsync(context, campagneId, cancellationToken).ConfigureAwait(false);
            if (dmUserId == null)
            {
                return null;
            }

            var openFights = await LoadOpenFightsAsync(context, campagneId, cancellationToken).ConfigureAwait(false);
            var expired = openFights.Where(IsInactive).ToList();
            foreach (var fight in expired)
            {
                Expire(fight);
            }

            if (expired.Count > 0)
            {
                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            }

            var current = openFights.Except(expired).OrderByDescending(f => f.StartedAt).FirstOrDefault();
            return current == null ? null : ToSnapshot(current, dmUserId.Value);
        }
        finally
        {
            _writeLock.Release();
        }
    }

    public async Task<FightOperationResult> StartAsync(
        Guid campagneId,
        Guid actorUserId,
        Guid? requestedFightId,
        IReadOnlyList<FightParticipantRequest> participants,
        IReadOnlyList<FightEnemyRequest> enemies,
        bool skipUnknownParticipants,
        CancellationToken cancellationToken
    )
    {
        var enemyError = ValidateEnemies(enemies);
        if (enemyError != null)
        {
            return FightOperationResult.Fail(FightError.Invalid, enemyError);
        }

        if (participants.Any(p => string.IsNullOrWhiteSpace(p.CharacterUuid)))
        {
            return FightOperationResult.Fail(FightError.Invalid, "Every participant needs a characterUuid.");
        }

        if (participants.Any(p => p.Name?.Length > MaxNameLength))
        {
            return FightOperationResult.Fail(
                FightError.Invalid,
                $"Participant names must not be longer than {MaxNameLength} characters."
            );
        }

        await _writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
            var dmUserId = await GetDmUserIdAsync(context, campagneId, cancellationToken).ConfigureAwait(false);
            if (dmUserId == null)
            {
                return FightOperationResult.Fail(FightError.NotFound, "Campagne not found.");
            }

            if (dmUserId != actorUserId)
            {
                return FightOperationResult.Fail(FightError.NotAllowed, "Only the DM can start a fight.");
            }

            var characters = await context
                .PlayerCharacters.Where(pc => pc.CampagneId == campagneId)
                .Select(pc => new CampagneCharacter(pc.Id, pc.PlayerUserId, pc.CharacterName, pc.RpgCharacterConfiguration))
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            var combatants = FightCharacterResolver
                .ListCombatants(characters)
                .ToDictionary(c => c.CharacterUuid, StringComparer.Ordinal);

            var now = _systemClock.Now;
            var fight = new FightEntity
            {
                Id = Guid.NewGuid(),
                CampagneId = campagneId,
                StartedAt = now,
                LastActivityAt = now,
                Revision = 1,
            };

            var unknown = new List<string>();
            foreach (var request in participants.DistinctBy(p => p.CharacterUuid))
            {
                var participant = ResolveParticipant(request, combatants, characters);
                if (participant == null)
                {
                    unknown.Add(request.CharacterUuid);
                    continue;
                }

                fight.Participants.Add(participant);
            }

            if (unknown.Count > 0 && !skipUnknownParticipants)
            {
                return FightOperationResult.Fail(
                    FightError.Invalid,
                    $"Not a character or companion of this campagne: {string.Join(", ", unknown)}"
                );
            }

            var ordered = new List<FightParticipantEntity>();
            foreach (var enemy in enemies)
            {
                var enemyEntity = NewEnemy(enemy, now);
                fight.Participants.Add(enemyEntity);
                PlaceByRoll(ordered, enemyEntity);
            }

            Renumber(ordered);

            FightSnapshot? replaced = null;
            foreach (var openFight in await LoadOpenFightsAsync(context, campagneId, cancellationToken).ConfigureAwait(false))
            {
                if (IsInactive(openFight))
                {
                    Expire(openFight);
                    continue;
                }

                End(openFight, FightEndReason.ReplacedByNewFight, now);
                replaced = ToSnapshot(openFight, dmUserId.Value);
            }

            if (
                requestedFightId is Guid requestedId
                && !await context.Fights.AnyAsync(f => f.Id == requestedId, cancellationToken).ConfigureAwait(false)
            )
            {
                fight.Id = requestedId;
            }

            context.Fights.Add(fight);
            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            return FightOperationResult.Ok(ToSnapshot(fight, dmUserId.Value), replaced);
        }
        finally
        {
            _writeLock.Release();
        }
    }

    public Task<FightOperationResult> SubmitRollsAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<FightRollRequest> rolls,
        bool skipInvalidRolls,
        CancellationToken cancellationToken
    )
    {
        var outOfRange = rolls.Where(r => r.Roll < MinRoll || r.Roll > MaxRoll).ToList();
        if (outOfRange.Count > 0 && !skipInvalidRolls)
        {
            return Task.FromResult(
                FightOperationResult.Fail(FightError.Invalid, $"Rolls must be between {MinRoll} and {MaxRoll}.")
            );
        }

        var validRolls = rolls.Except(outOfRange).DistinctBy(r => r.CharacterUuid).ToList();

        return WriteFightAsync(
            fightId,
            actorUserId,
            requireDm: false,
            (_, fight, dmUserId, now) =>
            {
                var unknown = new List<string>();
                var foreign = new List<string>();
                var alreadyRolled = new List<string>();
                var applicable = new List<(FightParticipantEntity Participant, int Roll)>();

                foreach (var roll in validRolls)
                {
                    var participant = fight.Participants.FirstOrDefault(p =>
                        p.Kind != FightParticipantKind.Enemy && p.CharacterUuid == roll.CharacterUuid
                    );

                    if (participant == null)
                    {
                        unknown.Add(roll.CharacterUuid);
                    }
                    else if (participant.OwnerUserId != actorUserId && dmUserId != actorUserId)
                    {
                        foreign.Add(participant.Name);
                    }
                    else if (participant.Roll != null)
                    {
                        alreadyRolled.Add(participant.Name);
                    }
                    else
                    {
                        applicable.Add((participant, roll.Roll));
                    }
                }

                if (!skipInvalidRolls)
                {
                    if (unknown.Count > 0)
                    {
                        return FightOperationResult.Fail(
                            FightError.Invalid,
                            $"Not part of this fight: {string.Join(", ", unknown)}"
                        );
                    }

                    if (foreign.Count > 0)
                    {
                        return FightOperationResult.Fail(
                            FightError.NotAllowed,
                            $"You cannot roll for {string.Join(", ", foreign)}."
                        );
                    }

                    if (alreadyRolled.Count > 0)
                    {
                        return FightOperationResult.Fail(
                            FightError.Conflict,
                            $"Already rolled: {string.Join(", ", alreadyRolled)}"
                        );
                    }
                }

                if (applicable.Count == 0)
                {
                    return FightOperationResult.Ok(ToSnapshot(fight, dmUserId), changed: false);
                }

                var ordered = OrderedParticipants(fight);
                foreach (var (participant, roll) in applicable)
                {
                    participant.Roll = roll;
                    participant.RolledAt = now;
                    PlaceByRoll(ordered, participant);
                }

                Renumber(ordered);
                Touch(fight, now);

                var snapshot = ToSnapshot(fight, dmUserId);
                var rolledIds = applicable.Select(a => a.Participant.Id).ToHashSet();
                return FightOperationResult.Ok(
                    snapshot,
                    rolled: snapshot.Participants.Where(p => rolledIds.Contains(p.Id)).ToList()
                );
            },
            cancellationToken
        );
    }

    public Task<FightOperationResult> AddEnemiesAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<FightEnemyRequest> enemies,
        CancellationToken cancellationToken
    )
    {
        var enemyError = enemies.Count == 0 ? "Add at least one enemy." : ValidateEnemies(enemies);
        if (enemyError != null)
        {
            return Task.FromResult(FightOperationResult.Fail(FightError.Invalid, enemyError));
        }

        return WriteFightAsync(
            fightId,
            actorUserId,
            requireDm: true,
            (context, fight, dmUserId, now) =>
            {
                var ordered = OrderedParticipants(fight);
                foreach (var enemy in enemies)
                {
                    // Added explicitly: EF would take a new participant with a preset id for an existing row.
                    var enemyEntity = NewEnemy(enemy, now);
                    context.FightParticipants.Add(enemyEntity);
                    fight.Participants.Add(enemyEntity);
                    PlaceByRoll(ordered, enemyEntity);
                }

                Renumber(ordered);
                Touch(fight, now);
                return FightOperationResult.Ok(ToSnapshot(fight, dmUserId));
            },
            cancellationToken
        );
    }

    public Task<FightOperationResult> ReorderAsync(
        Guid fightId,
        Guid actorUserId,
        IReadOnlyList<Guid> participantIds,
        CancellationToken cancellationToken
    ) =>
        WriteFightAsync(
            fightId,
            actorUserId,
            requireDm: true,
            (_, fight, dmUserId, now) =>
            {
                var ordered = OrderedParticipants(fight);
                var sameParticipants =
                    participantIds.Count == ordered.Count
                    && participantIds.ToHashSet().SetEquals(ordered.Select(p => p.Id));
                if (!sameParticipants)
                {
                    return FightOperationResult.Fail(
                        FightError.Conflict,
                        "The order must list every participant that has a roll. Reload the fight and try again."
                    );
                }

                var byId = ordered.ToDictionary(p => p.Id);
                Renumber(participantIds.Select(id => byId[id]).ToList());
                Touch(fight, now);
                return FightOperationResult.Ok(ToSnapshot(fight, dmUserId));
            },
            cancellationToken
        );

    public Task<FightOperationResult> RemoveParticipantAsync(
        Guid fightId,
        Guid actorUserId,
        Guid participantId,
        CancellationToken cancellationToken
    ) =>
        WriteFightAsync(
            fightId,
            actorUserId,
            requireDm: true,
            (context, fight, dmUserId, now) =>
            {
                var participant = fight.Participants.FirstOrDefault(p => p.Id == participantId);
                if (participant == null)
                {
                    return FightOperationResult.Fail(FightError.NotFound, "Participant not found in this fight.");
                }

                var removed = ToSnapshot(participant);
                context.FightParticipants.Remove(participant);
                fight.Participants.Remove(participant);
                Renumber(OrderedParticipants(fight));
                Touch(fight, now);
                return FightOperationResult.Ok(ToSnapshot(fight, dmUserId), removed: new[] { removed });
            },
            cancellationToken
        );

    public async Task<FightOperationResult> EndAsync(Guid fightId, Guid actorUserId, CancellationToken cancellationToken)
    {
        await _writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
            var fight = await LoadFightAsync(context, fightId, cancellationToken).ConfigureAwait(false);
            var dmUserId = fight == null
                ? null
                : await GetDmUserIdAsync(context, fight.CampagneId, cancellationToken).ConfigureAwait(false);
            if (fight == null || dmUserId == null)
            {
                return FightOperationResult.Fail(FightError.NotFound, "Fight not found.");
            }

            if (dmUserId != actorUserId)
            {
                return await NotAllowedOrNotFoundAsync(context, fight.CampagneId, actorUserId, cancellationToken)
                    .ConfigureAwait(false);
            }

            if (fight.EndedAt != null)
            {
                return FightOperationResult.Ok(ToSnapshot(fight, dmUserId.Value), changed: false);
            }

            if (IsInactive(fight))
            {
                Expire(fight);
            }
            else
            {
                End(fight, FightEndReason.EndedByDm, _systemClock.Now);
            }

            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return FightOperationResult.Ok(ToSnapshot(fight, dmUserId.Value));
        }
        finally
        {
            _writeLock.Release();
        }
    }

    /// <summary>
    /// Inserts <paramref name="newcomer"/> before the first participant whose roll is lower or equal, the same
    /// rule the app used when it kept the order locally.
    /// </summary>
    internal static void PlaceByRoll(List<FightParticipantEntity> ordered, FightParticipantEntity newcomer)
    {
        var index = ordered.FindIndex(p => p.Roll <= newcomer.Roll);
        ordered.Insert(index < 0 ? ordered.Count : index, newcomer);
    }

    private static void Renumber(List<FightParticipantEntity> ordered)
    {
        for (var i = 0; i < ordered.Count; i++)
        {
            ordered[i].Position = i;
        }
    }

    private static List<FightParticipantEntity> OrderedParticipants(FightEntity fight) =>
        fight.Participants.Where(p => p.Position != null).OrderBy(p => p.Position).ToList();

    private static FightParticipantEntity? ResolveParticipant(
        FightParticipantRequest request,
        IReadOnlyDictionary<string, FightCombatant> combatants,
        IReadOnlyList<CampagneCharacter> characters
    )
    {
        var name = string.IsNullOrWhiteSpace(request.Name) ? null : request.Name.Trim();

        if (
            combatants.TryGetValue(request.CharacterUuid, out var combatant)
            && (request.PlayerCharacterId == null || request.PlayerCharacterId == combatant.PlayerCharacterId)
        )
        {
            return NewParticipant(
                combatant.Kind,
                request.CharacterUuid,
                combatant.PlayerCharacterId,
                combatant.OwnerUserId,
                name ?? combatant.Name
            );
        }

        // A character whose stored configuration has no uuid yet: trust the uuid when the caller names the character.
        var character = characters.FirstOrDefault(c => c.PlayerCharacterId == request.PlayerCharacterId);
        if (character != null && !combatants.ContainsKey(request.CharacterUuid))
        {
            return NewParticipant(
                FightParticipantKind.Character,
                request.CharacterUuid,
                character.PlayerCharacterId,
                character.OwnerUserId,
                name ?? character.CharacterName
            );
        }

        return null;
    }

    private static FightParticipantEntity NewParticipant(
        FightParticipantKind kind,
        string characterUuid,
        Guid playerCharacterId,
        Guid ownerUserId,
        string name
    ) =>
        new()
        {
            Id = Guid.NewGuid(),
            Kind = kind,
            CharacterUuid = characterUuid,
            PlayerCharacterId = playerCharacterId,
            OwnerUserId = ownerUserId,
            Name = name,
        };

    private static FightParticipantEntity NewEnemy(FightEnemyRequest enemy, DateTimeOffset now) =>
        new()
        {
            Id = Guid.NewGuid(),
            Kind = FightParticipantKind.Enemy,
            Name = enemy.Name.Trim(),
            Roll = enemy.Roll,
            RolledAt = now,
        };

    private static string? ValidateEnemies(IReadOnlyList<FightEnemyRequest> enemies)
    {
        if (enemies.Any(e => string.IsNullOrWhiteSpace(e.Name) || e.Name.Length > MaxNameLength))
        {
            return $"Every enemy needs a name of at most {MaxNameLength} characters.";
        }

        if (enemies.Any(e => e.Roll < MinRoll || e.Roll > MaxRoll))
        {
            return $"Rolls must be between {MinRoll} and {MaxRoll}.";
        }

        return null;
    }

    private static Task<Guid?> GetDmUserIdAsync(RpgDbContext context, Guid campagneId, CancellationToken cancellationToken) =>
        context.Campagnes.Where(c => c.Id == campagneId).Select(c => (Guid?)c.DmUserId).SingleOrDefaultAsync(cancellationToken);

    private static Task<List<FightEntity>> LoadOpenFightsAsync(
        RpgDbContext context,
        Guid campagneId,
        CancellationToken cancellationToken
    ) =>
        context
            .Fights.Include(f => f.Participants)
            .Where(f => f.CampagneId == campagneId && f.EndedAt == null)
            .ToListAsync(cancellationToken);

    private static Task<FightEntity?> LoadFightAsync(RpgDbContext context, Guid fightId, CancellationToken cancellationToken) =>
        context.Fights.Include(f => f.Participants).SingleOrDefaultAsync(f => f.Id == fightId, cancellationToken);

    private static async Task<FightOperationResult> NotAllowedOrNotFoundAsync(
        RpgDbContext context,
        Guid campagneId,
        Guid actorUserId,
        CancellationToken cancellationToken
    )
    {
        // Players of the campagne learn that only the DM may do this; everybody else does not learn the fight exists.
        var isMember = await context
            .PlayerCharacters.AnyAsync(pc => pc.CampagneId == campagneId && pc.PlayerUserId == actorUserId, cancellationToken)
            .ConfigureAwait(false);
        return isMember
            ? FightOperationResult.Fail(FightError.NotAllowed, "Only the DM can do this.")
            : FightOperationResult.Fail(FightError.NotFound, "Fight not found.");
    }

    private static void Touch(FightEntity fight, DateTimeOffset now)
    {
        fight.LastActivityAt = now;
        fight.Revision++;
    }

    private static void End(FightEntity fight, FightEndReason reason, DateTimeOffset now)
    {
        fight.EndedAt = now;
        fight.EndReason = reason;
        fight.Revision++;
    }

    private static void Expire(FightEntity fight) =>
        End(fight, FightEndReason.Expired, fight.LastActivityAt + InactivityTimeout);

    private static FightSnapshot ToSnapshot(FightEntity fight, Guid dmUserId) =>
        new(
            fight.Id,
            fight.CampagneId,
            dmUserId,
            fight.StartedAt,
            fight.LastActivityAt,
            fight.EndedAt,
            fight.EndReason,
            fight.Revision,
            fight
                .Participants.OrderBy(p => p.Position ?? int.MaxValue)
                .ThenBy(p => p.Name, StringComparer.CurrentCulture)
                .Select(ToSnapshot)
                .ToList()
        );

    private static FightParticipantSnapshot ToSnapshot(FightParticipantEntity participant) =>
        new(
            participant.Id,
            participant.Kind,
            participant.CharacterUuid,
            participant.PlayerCharacterId,
            participant.OwnerUserId,
            participant.Name,
            participant.Roll,
            participant.RolledAt,
            participant.Position
        );

    private bool IsInactive(FightEntity fight) => fight.LastActivityAt + InactivityTimeout <= _systemClock.Now;

    private async Task<FightOperationResult> WriteFightAsync(
        Guid fightId,
        Guid actorUserId,
        bool requireDm,
        Func<RpgDbContext, FightEntity, Guid, DateTimeOffset, FightOperationResult> change,
        CancellationToken cancellationToken
    )
    {
        await _writeLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
            var fight = await LoadFightAsync(context, fightId, cancellationToken).ConfigureAwait(false);
            var dmUserId = fight == null
                ? null
                : await GetDmUserIdAsync(context, fight.CampagneId, cancellationToken).ConfigureAwait(false);
            if (fight == null || dmUserId == null)
            {
                return FightOperationResult.Fail(FightError.NotFound, "Fight not found.");
            }

            if (requireDm && dmUserId != actorUserId)
            {
                return await NotAllowedOrNotFoundAsync(context, fight.CampagneId, actorUserId, cancellationToken)
                    .ConfigureAwait(false);
            }

            if (!requireDm && dmUserId != actorUserId)
            {
                var isMember = await context
                    .PlayerCharacters.AnyAsync(
                        pc => pc.CampagneId == fight.CampagneId && pc.PlayerUserId == actorUserId,
                        cancellationToken
                    )
                    .ConfigureAwait(false);
                if (!isMember)
                {
                    return FightOperationResult.Fail(FightError.NotFound, "Fight not found.");
                }
            }

            if (fight.EndedAt == null && IsInactive(fight))
            {
                Expire(fight);
                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            }

            if (fight.EndedAt != null)
            {
                return FightOperationResult.Fail(FightError.Ended, "This fight is over.");
            }

            var result = change(context, fight, dmUserId.Value, _systemClock.Now);
            if (result.Succeeded && result.Changed)
            {
                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            }

            return result;
        }
        finally
        {
            _writeLock.Release();
        }
    }
}
