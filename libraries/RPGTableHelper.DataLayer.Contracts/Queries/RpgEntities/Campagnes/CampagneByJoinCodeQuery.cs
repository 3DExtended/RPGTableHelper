using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes
{
    public class CampagneByJoinCodeQuery : IQuery<Campagne, CampagneByJoinCodeQuery>
    {
        public string JoinCode { get; set; } = default!;
    }
}
