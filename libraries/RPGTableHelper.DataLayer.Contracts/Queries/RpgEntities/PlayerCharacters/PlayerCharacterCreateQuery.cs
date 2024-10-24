using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters
{
    public class PlayerCharacterCreateQuery
        : CreateQuery<
            PlayerCharacter,
            PlayerCharacter.PlayerCharacterIdentifier,
            Guid,
            PlayerCharacterCreateQuery
        > { }
}
