using Prodot.Patterns.Cqrs.EfCore;

namespace RPGTableHelper.DataLayer.Contracts.Models.BaseModels
{
    public abstract class NodeModelBase<TIdentifier, TIdentifierValue>
        : ModelBase<TIdentifier, TIdentifierValue>
        where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
    {
        public DateTimeOffset CreationDate { get; set; }

        public DateTimeOffset LastModifiedAt { get; set; }
    }
}
