using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters
{
    public class PlayerCharactersForCampagneQuery
        : IQuery<IReadOnlyList<PlayerCharacter>, PlayerCharactersForCampagneQuery>
    {
        public Campagne.CampagneIdentifier CampagneId { get; set; } = default!;
    }
}
