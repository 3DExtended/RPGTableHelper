using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestDeleteQuery
        : DeleteCommand<
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            CampagneJoinRequestDeleteQuery
        > { }
}
