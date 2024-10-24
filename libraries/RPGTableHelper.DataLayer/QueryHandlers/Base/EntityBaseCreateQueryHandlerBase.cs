using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;
using RPGTableHelper.DataLayer.Entities.Base;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers
{
    public abstract class EntityBaseCreateQueryHandlerBase<
        TQuery,
        TModel,
        TIdentifier,
        TIdentifierValue,
        TContext,
        TEntity
    > : CreateQueryHandlerBase<TQuery, TModel, TIdentifier, TIdentifierValue, TContext, TEntity>
        where TQuery : CreateQuery<TModel, TIdentifier, TIdentifierValue, TQuery>
        where TModel : NodeModelBase<TIdentifier, TIdentifierValue>
        where TIdentifier : Identifier<TIdentifierValue, TIdentifier>, new()
        where TContext : DbContext
        where TEntity : EntityBase<TIdentifierValue>
    {
        private readonly ISystemClock _systemClock;

        protected EntityBaseCreateQueryHandlerBase(
            IMapper mapper,
            IDbContextFactory<TContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory)
        {
            _systemClock = systemClock;
        }

        protected override Task<Option<TModel>> PrepareModelAsync(
            TModel model,
            TContext context,
            CancellationToken cancellationToken
        )
        {
            var now = _systemClock.Now;

            var modelWithTimesSet = model;

            modelWithTimesSet.CreationDate = now;
            modelWithTimesSet.LastModifiedAt = now;
            return Task.FromResult(Option.From(modelWithTimesSet));
        }
    }
}
