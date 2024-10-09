using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using Prodot.Patterns.Cqrs.EfCore.Tests.TestHelpers.Context;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers
{
    public class UserCreateQueryHandler
        : CreateQueryHandlerBase<
            UserCreateQuery,
            User,
            User.UserIdentifier,
            Guid,
            RpgDbContext,
            UserEntity
        >
    {
        public UserCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
            : base(mapper, contextFactory) { }
    }
}
