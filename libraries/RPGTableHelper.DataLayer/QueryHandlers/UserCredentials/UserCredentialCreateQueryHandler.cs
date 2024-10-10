using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.UserCredentials
{
    public class UserCredentialCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            UserCredentialCreateQuery,
            UserCredential,
            UserCredential.UserCredentialIdentifier,
            Guid,
            RpgDbContext,
            UserCredentialEntity
        >
    {
        public UserCredentialCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
