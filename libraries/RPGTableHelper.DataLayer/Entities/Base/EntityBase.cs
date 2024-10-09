using Prodot.Patterns.Cqrs.EfCore;

namespace RPGTableHelper.DataLayer.Entities.Base
{
    public abstract class EntityBase<TIdentifierValue> : IIdentifiableEntity<TIdentifierValue>
    {
        public TIdentifierValue Id { get; set; } = default!;

        public DateTimeOffset CreationDate { get; set; }

        public DateTimeOffset LastModifiedAt { get; set; }
    }
}
