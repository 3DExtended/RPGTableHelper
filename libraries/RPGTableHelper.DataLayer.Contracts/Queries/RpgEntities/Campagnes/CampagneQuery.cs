using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagneQuery
        : SingleModelQuery<Campagne, Campagne.CampagneIdentifier, Guid, CampagneQuery> { }
}
