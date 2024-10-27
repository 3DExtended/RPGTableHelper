using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UsersQueryHandler
        : ListOfModelQueryHandlerBase<
            UsersQuery,
            User,
            User.UserIdentifier,
            Guid,
            RpgDbContext,
            UserEntity
        >
    {
        public UsersQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }
    }
}
