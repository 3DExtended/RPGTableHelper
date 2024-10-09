using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public static class RpgDbContextHelpers
{
    public static async Task<User> CreateUserInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var user = new User { Username = "User1" };
        using (var context = contextFactory.CreateDbContext())
        {
            var userEntity = mapper.Map<UserEntity>(user);
            await context.Users.AddAsync(userEntity, cancellationToken);
            await context.SaveChangesAsync();

            return mapper.Map<User>(userEntity);
        }
    }

    public static async Task<(User, EncryptionChallenge)> CreateUserWithEncryptionChallengeInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var user = await CreateUserInDb(contextFactory, mapper, cancellationToken);
        var encryptionChallengeForUser = new EncryptionChallenge
        {
            UserId = user.Id,
            PasswordPrefix = "asdfgeh",
            RndInt = 5678,
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var challengeEntity = mapper.Map<EncryptionChallengeEntity>(encryptionChallengeForUser);
            await context.EncryptionChallenges.AddAsync(challengeEntity, cancellationToken);
            await context.SaveChangesAsync();

            return (user, mapper.Map<EncryptionChallenge>(challengeEntity));
        }
    }
}
