using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
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
        var user = new User
        {
            Username = "User1",
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
        };

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
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var challengeEntity = mapper.Map<EncryptionChallengeEntity>(encryptionChallengeForUser);
            await context.EncryptionChallenges.AddAsync(challengeEntity, cancellationToken);
            await context.SaveChangesAsync();

            return (user, mapper.Map<EncryptionChallenge>(challengeEntity));
        }
    }

    public static async Task<(
        User,
        EncryptionChallenge,
        UserCredential
    )> CreateUserWithEncryptionChallengeAndCredentialsInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var (user, encryptionChallenge) = await CreateUserWithEncryptionChallengeInDb(
            contextFactory,
            mapper,
            cancellationToken
        );

        var userCredential = new UserCredential
        {
            UserId = user.Id,
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            EmailVerified = false,
            Email = "asdf@asdf.de",
            Deleted = false,
            EncryptionChallengeId = encryptionChallenge.Id,
            HashedPassword = "asdfhjk",
            Id = UserCredential.UserCredentialIdentifier.From(Guid.Empty),
            PasswordResetToken = Option.None,
            PasswordResetTokenExpireDate = Option.None,
            RefreshToken = Option.None,
            SignInProvider = false,
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var credentialEntity = mapper.Map<UserCredentialEntity>(userCredential);
            await context.UserCredentials.AddAsync(credentialEntity, cancellationToken);
            await context.SaveChangesAsync();

            return (user, encryptionChallenge, mapper.Map<UserCredential>(credentialEntity));
        }
    }
}
