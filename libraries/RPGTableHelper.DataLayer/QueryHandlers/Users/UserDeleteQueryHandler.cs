using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UserDeleteQueryHandler
        : DeleteCommandHandlerBase<
            UserDeleteQuery,
            User,
            User.UserIdentifier,
            Guid,
            RpgDbContext,
            UserEntity
        >
    {
        public UserDeleteQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
            : base(contextFactory) { }
    }
}
