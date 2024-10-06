using RPGTableHelper.DataLayer.Contracts.Models;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Base
{
    public class ModificationNodeCreateQuery
        : ConditionalCreateQueryBase<
            ModificationNode,
            ModificationNode.ModificationNodeIdentifier,
            Guid,
            ModificationNodeCreateQuery
        >
    {
        public Guid RelatedEntityId { get; set; } = default!;
    }
}
