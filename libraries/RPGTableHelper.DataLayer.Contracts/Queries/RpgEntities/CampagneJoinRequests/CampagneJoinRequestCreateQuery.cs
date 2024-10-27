using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestCreateQuery
        : CreateQuery<
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            CampagneJoinRequestCreateQuery
        > { }
}
