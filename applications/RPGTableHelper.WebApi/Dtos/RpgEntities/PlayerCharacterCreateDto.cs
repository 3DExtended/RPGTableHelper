using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities
{
    public class PlayerCharacterCreateDto
    {
        /// <summary>
        /// This is the json serialized configuration of the character
        /// </summary>
        public string? RpgCharacterConfiguration { get; set; }

        [Required]
        public string CharacterName { get; set; } = default!;

        /// <summary>
        /// The id of the campagne for this character
        /// </summary>
        public Guid? CampagneId { get; set; }
    }
}
