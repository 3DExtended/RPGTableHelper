using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Base
{
    public class ConditionalCreateQueryBase<TModel, TIdentifier, TIdentifierValue, TSelf>
        : IQuery<(TIdentifier Identifier, bool CreatedNewInstance), TSelf>
        where TModel : ModelBase<TIdentifier, TIdentifierValue>
        where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        where TSelf : ConditionalCreateQueryBase<TModel, TIdentifier, TIdentifierValue, TSelf>
    {
        public TModel ModelToCreate { get; init; } = default!;
    }
}
