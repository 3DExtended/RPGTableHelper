using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities
{
    public class CampagneJoinRequestCreateDto
    {
        [Required]
        public string CampagneJoinCode { get; set; } = default!;

        [Required]
        public string PlayerCharacterId { get; set; } = default!;
    }
}
