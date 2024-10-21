using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities
{
    public class CampagneCreateDto
    {
        /// <summary>
        /// This is the json serialized configuration of the rpg
        /// </summary>
        public string? RpgConfiguration { get; set; }

        [Required]
        public string CampagneName { get; set; } = default!;
    }
}
