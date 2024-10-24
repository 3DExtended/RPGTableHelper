using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagneUpdateQuery
        : UpdateCommand<Campagne, Campagne.CampagneIdentifier, Guid, CampagneUpdateQuery> { }
}
