using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests
{
    public class OpenSignInProviderRegisterRequestCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            OpenSignInProviderRegisterRequestCreateQuery,
            OpenSignInProviderRegisterRequest,
            OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
            Guid,
            RpgDbContext,
            OpenSignInProviderRegisterRequestEntity
        >
    {
        public OpenSignInProviderRegisterRequestCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
