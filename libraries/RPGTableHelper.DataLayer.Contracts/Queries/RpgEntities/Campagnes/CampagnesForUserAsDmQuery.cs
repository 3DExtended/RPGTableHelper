using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagnesForUserAsDmQuery
        : IQuery<IReadOnlyList<Campagne>, CampagnesForUserAsDmQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
