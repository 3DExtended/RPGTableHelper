using RPGTableHelper.DataLayer.Contracts.Models.Fights;

namespace RPGTableHelper.WebApi.Services.Fights;

/// <summary>A fight as stored, independent of who looks at it.</summary>
public sealed record FightSnapshot
{
    public FightSnapshot(
        Guid id,
        Guid campagneId,
        Guid dmUserId,
        DateTimeOffset startedAt,
        DateTimeOffset lastActivityAt,
        DateTimeOffset? endedAt,
        FightEndReason? endReason,
        int revision,
        IReadOnlyList<FightParticipantSnapshot> participants
    )
    {
        Id = id;
        CampagneId = campagneId;
        DmUserId = dmUserId;
        StartedAt = startedAt;
        LastActivityAt = lastActivityAt;
        EndedAt = endedAt;
        EndReason = endReason;
        Revision = revision;
        Participants = participants;
    }

    public Guid Id { get; }

    public Guid CampagneId { get; }

    public Guid DmUserId { get; }

    public DateTimeOffset StartedAt { get; }

    public DateTimeOffset LastActivityAt { get; }

    public DateTimeOffset? EndedAt { get; }

    public FightEndReason? EndReason { get; }

    public int Revision { get; }

    public IReadOnlyList<FightParticipantSnapshot> Participants { get; }

    public bool IsOpen => EndedAt == null;

    /// <summary>Participants with a roll, in initiative order.</summary>
    public IEnumerable<FightParticipantSnapshot> Ordered =>
        Participants.Where(p => p.Position != null).OrderBy(p => p.Position);

    /// <summary>Characters and companions that still wait for their owner to roll.</summary>
    public IEnumerable<FightParticipantSnapshot> Pending => Participants.Where(p => p.IsPending);

    public IEnumerable<FightParticipantSnapshot> PendingFor(Guid userId) => Pending.Where(p => p.OwnerUserId == userId);
}

public sealed record FightParticipantSnapshot
{
    public FightParticipantSnapshot(
        Guid id,
        FightParticipantKind kind,
        string? characterUuid,
        Guid? playerCharacterId,
        Guid? ownerUserId,
        string name,
        int? roll,
        DateTimeOffset? rolledAt,
        int? position
    )
    {
        Id = id;
        Kind = kind;
        CharacterUuid = characterUuid;
        PlayerCharacterId = playerCharacterId;
        OwnerUserId = ownerUserId;
        Name = name;
        Roll = roll;
        RolledAt = rolledAt;
        Position = position;
    }

    public Guid Id { get; }

    public FightParticipantKind Kind { get; }

    public string? CharacterUuid { get; }

    public Guid? PlayerCharacterId { get; }

    public Guid? OwnerUserId { get; }

    public string Name { get; }

    public int? Roll { get; }

    public DateTimeOffset? RolledAt { get; }

    public int? Position { get; }

    public bool IsPending => Roll == null && Kind != FightParticipantKind.Enemy;
}

/// <summary>A character or companion the DM wants to ask for initiative.</summary>
/// <param name="characterUuid">The <c>uuid</c> inside the character configuration.</param>
/// <param name="playerCharacterId">The owning player character, if the caller knows it.</param>
/// <param name="name">Display name; defaults to the name in the character configuration.</param>
public sealed record FightParticipantRequest
{
    public FightParticipantRequest(
        string characterUuid,
        Guid? playerCharacterId,
        string? name
    )
    {
        CharacterUuid = characterUuid;
        PlayerCharacterId = playerCharacterId;
        Name = name;
    }

    public string CharacterUuid { get; }

    public Guid? PlayerCharacterId { get; }

    public string? Name { get; }
}

public sealed record FightEnemyRequest
{
    public FightEnemyRequest(
        string name,
        int roll
    )
    {
        Name = name;
        Roll = roll;
    }

    public string Name { get; }

    public int Roll { get; }
}

public sealed record FightRollRequest
{
    public FightRollRequest(
        string characterUuid,
        int roll
    )
    {
        CharacterUuid = characterUuid;
        Roll = roll;
    }

    public string CharacterUuid { get; }

    public int Roll { get; }
}

/// <summary>What the caller may see of a campagne's fights.</summary>
public enum FightAccess
{
    None,
    Player,
    Dm,
}

public enum FightError
{
    None,
    NotFound,
    NotAllowed,
    Ended,
    Conflict,
    Invalid,
}

/// <summary>Outcome of a fight write.</summary>
public sealed class FightOperationResult
{
    private FightOperationResult(
        FightError error,
        string? message,
        FightSnapshot? fight,
        FightSnapshot? replacedFight,
        IReadOnlyList<FightParticipantSnapshot> rolled,
        bool changed
    )
    {
        Error = error;
        Changed = changed;
        Message = message;
        Fight = fight;
        ReplacedFight = replacedFight;
        Rolled = rolled;
    }

    public FightError Error { get; }

    public string? Message { get; }

    /// <summary>The fight after the write; set when <see cref="Error"/> is <see cref="FightError.None"/>.</summary>
    public FightSnapshot? Fight { get; }

    /// <summary>The fight a start ended, if one was open.</summary>
    public FightSnapshot? ReplacedFight { get; }

    /// <summary>The participants that got their roll in this write.</summary>
    public IReadOnlyList<FightParticipantSnapshot> Rolled { get; }

    /// <summary>False when the write was a no-op, e.g. ending a fight that is already over.</summary>
    public bool Changed { get; }

    public bool Succeeded => Error == FightError.None;

    public static FightOperationResult Ok(
        FightSnapshot fight,
        FightSnapshot? replacedFight = null,
        IReadOnlyList<FightParticipantSnapshot>? rolled = null,
        bool changed = true
    ) => new(FightError.None, null, fight, replacedFight, rolled ?? Array.Empty<FightParticipantSnapshot>(), changed);

    public static FightOperationResult Fail(FightError error, string message) =>
        new(error, message, null, null, Array.Empty<FightParticipantSnapshot>(), false);
}
