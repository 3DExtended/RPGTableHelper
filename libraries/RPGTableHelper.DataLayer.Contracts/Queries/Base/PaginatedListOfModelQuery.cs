using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Base
{
    public abstract class PaginatedListOfModelQuery<
        TModel,
        TIdentifier,
        TIdentifierValue,
        TResult,
        TSelf
    > : IQuery<TResult, TSelf>
        where TModel : ModelBase<TIdentifier, TIdentifierValue>
        where TResult : PaginatedResult<TModel, TIdentifier, TIdentifierValue>
        where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        where TSelf : PaginatedListOfModelQuery<
                TModel,
                TIdentifier,
                TIdentifierValue,
                TResult,
                TSelf
            >
    {
        public bool AllowPartialResultSet { get; init; }

        public Option<PaginationCursor> Cursor { get; set; } = Option.None;

        public Option<IReadOnlyList<TIdentifier>> Ids { get; init; } = default!;

        public int PageSize { get; set; } = default!;
    }
}
