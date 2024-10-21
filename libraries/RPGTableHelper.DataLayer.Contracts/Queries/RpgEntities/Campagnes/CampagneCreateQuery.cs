using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagneCreateQuery
        : CreateQuery<Campagne, Campagne.CampagneIdentifier, Guid, CampagneCreateQuery> { }
}
