using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestsForCampagneQuery
        : IQuery<
            IReadOnlyList<(CampagneJoinRequest request, PlayerCharacter playerCharacter, string username)>,
            CampagneJoinRequestsForCampagneQuery
        >
    {
        public Campagne.CampagneIdentifier CampagneId { get; set; } = default!;
    }
}
