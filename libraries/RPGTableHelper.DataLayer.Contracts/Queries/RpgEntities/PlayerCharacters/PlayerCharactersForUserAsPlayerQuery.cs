using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters
{
    public class PlayerCharactersForUserAsPlayerQuery
        : IQuery<IReadOnlyList<PlayerCharacter>, PlayerCharactersForUserAsPlayerQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
