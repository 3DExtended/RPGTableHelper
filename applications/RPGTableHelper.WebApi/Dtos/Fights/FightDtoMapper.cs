using RPGTableHelper.WebApi.Services.Fights;

namespace RPGTableHelper.WebApi.Dtos.Fights;

public static class FightDtoMapper
{
    /// <summary>The DM's view: every participant, positions included.</summary>
    public static FightDto ToDmDto(FightSnapshot fight) => ToDto(fight, isDmView: true, fight.Participants);

    /// <summary>A player's view: only participants <paramref name="viewerUserId"/> rolls for, without positions.</summary>
    public static FightDto ToPlayerDto(FightSnapshot fight, Guid viewerUserId) =>
        ToDto(fight, isDmView: false, fight.Participants.Where(p => p.OwnerUserId == viewerUserId));

    public static FightDto ToDto(FightSnapshot fight, FightAccess access, Guid viewerUserId) =>
        access == FightAccess.Dm ? ToDmDto(fight) : ToPlayerDto(fight, viewerUserId);

    private static FightDto ToDto(FightSnapshot fight, bool isDmView, IEnumerable<FightParticipantSnapshot> participants) =>
        new()
        {
            Id = fight.Id,
            CampagneId = fight.CampagneId,
            StartedAt = fight.StartedAt,
            EndedAt = fight.EndedAt,
            EndReason = fight.EndReason,
            IsOpen = fight.IsOpen,
            Revision = fight.Revision,
            IsDmView = isDmView,
            Participants = participants
                .Select(p => new FightParticipantDto
                {
                    Id = p.Id,
                    Kind = p.Kind,
                    CharacterUuid = p.CharacterUuid,
                    PlayerCharacterId = p.PlayerCharacterId,
                    Name = p.Name,
                    Roll = p.Roll,
                    RolledAt = p.RolledAt,
                    Position = isDmView ? p.Position : null,
                    IsPending = p.IsPending,
                })
                .ToList(),
        };
}
