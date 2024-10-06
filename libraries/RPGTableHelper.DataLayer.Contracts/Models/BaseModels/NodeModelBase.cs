using Prodot.Patterns.Cqrs.EfCore;

namespace RPGTableHelper.DataLayer.Contracts.Models.BaseModels
{
    public abstract class NodeModelBase<TIdentifier> : ModelBase<TIdentifier, Guid>
        where TIdentifier : Identifier<Guid, TIdentifier>, new()
    {
        public DateTimeOffset CreationDate { get; set; }

        public DateTimeOffset LastModifiedAt { get; set; }

        public string PartitionKey { get; set; } = default!;
    }
}
