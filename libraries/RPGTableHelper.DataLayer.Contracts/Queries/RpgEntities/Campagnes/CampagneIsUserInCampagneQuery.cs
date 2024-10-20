using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagneIsUserInCampagneQuery : IQuery<bool, CampagneIsUserInCampagneQuery>
    {
        public User.UserIdentifier UserIdToCheck { get; set; } = default!;
        public Campagne.CampagneIdentifier CampagneId { get; set; } = default!;
    }
}
