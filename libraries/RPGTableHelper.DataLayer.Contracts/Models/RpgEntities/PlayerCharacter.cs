using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities
{
    public class PlayerCharacter : NodeModelBase<PlayerCharacter.PlayerCharacterIdentifier, Guid>
    {
        /// <summary>
        /// This is the json serialized configuration of the character
        /// </summary>
        public string? RpgCharacterConfiguration { get; set; }

        public string CharacterName { get; set; } = default!;

        /// <summary>
        /// The user of this character
        /// </summary>
        public User.UserIdentifier PlayerUserId { get; set; } = default!;

        /// <summary>
        /// The id of the campagne for this character
        /// </summary>
        public Campagne.CampagneIdentifier? CampagneId { get; set; }

        public record PlayerCharacterIdentifier : Identifier<Guid, PlayerCharacterIdentifier> { }
    }
}
