using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public enum HandleJoinRequestType
{
    Accept,
    Deny,
}

public class HandleJoinRequestDto
{
    [Required]
    public string CampagneJoinRequestId { get; set; } = default!;

    [Required]
    public HandleJoinRequestType Type { get; set; } = default!;
}
