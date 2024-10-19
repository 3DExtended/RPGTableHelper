using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.OpenSignInProviderRegisterRequests;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.OpenSignInProviderRegisterRequests
{
    public class OpenSignInProviderRegisterRequestDeleteQueryHandler
        : DeleteCommandHandlerBase<
            OpenSignInProviderRegisterRequestDeleteQuery,
            OpenSignInProviderRegisterRequest,
            OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
            Guid,
            RpgDbContext,
            OpenSignInProviderRegisterRequestEntity
        >
    {
        public OpenSignInProviderRegisterRequestDeleteQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory
        )
            : base(contextFactory) { }
    }
}
