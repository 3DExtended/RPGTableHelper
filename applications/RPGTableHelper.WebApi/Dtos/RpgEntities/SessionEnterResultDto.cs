namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

/// <summary>
/// Result of <c>POST /Session/enter/{campagneId}</c>: the caller is now present,
/// and <see cref="OnlineUserIds"/> is the full current online set for that campagne
/// (including the caller). Clients use this to hydrate presence without waiting for
/// SSE deltas that only fire for transitions.
/// </summary>
public class SessionEnterResultDto
{
    public List<string> OnlineUserIds { get; set; } = new();
}
