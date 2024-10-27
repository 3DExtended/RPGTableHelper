using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestQuery
        : SingleModelQuery<
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            CampagneJoinRequestQuery
        > { }
}
