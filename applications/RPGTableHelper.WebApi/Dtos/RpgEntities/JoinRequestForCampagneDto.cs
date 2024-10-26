using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class JoinRequestForCampagneDto
{
    [Required]
    public CampagneJoinRequest Request { get; set; } = default!;

    [Required]
    public PlayerCharacter PlayerCharacter { get; set; } = default!;

    [Required]
    public string Username { get; set; } = default!;
}
