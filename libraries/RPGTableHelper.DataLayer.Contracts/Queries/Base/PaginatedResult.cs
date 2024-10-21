using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Base
{
    public abstract class PaginatedResult<TModel, TIdentifier, TIdentifierValue>
        where TModel : ModelBase<TIdentifier, TIdentifierValue>
        where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
    {
        public PaginationCursor? AfterCursor { get; set; } = default!;

        public PaginationCursor? BeforeCursor { get; set; } = default!;

        public IReadOnlyList<TModel> Models { get; set; } = default!;
    }
}
