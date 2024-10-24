using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges
{
    public class EncryptionChallengeCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            EncryptionChallengeCreateQuery,
            EncryptionChallenge,
            EncryptionChallenge.EncryptionChallengeIdentifier,
            Guid,
            RpgDbContext,
            EncryptionChallengeEntity
        >
    {
        public EncryptionChallengeCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
