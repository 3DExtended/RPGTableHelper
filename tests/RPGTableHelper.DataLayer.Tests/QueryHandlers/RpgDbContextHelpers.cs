using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.Images;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.Tests.QueryHandlers;

public static class RpgDbContextHelpers
{
    public static async Task<Campagne> CreateCampagneInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        User dmOfCampagne,
        CancellationToken cancellationToken = default
    )
    {
        var campagne = new Campagne
        {
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            CampagneName = "asdf",
            DmUserId = dmOfCampagne.Id,
            JoinCode = "123-321",
            RpgConfiguration = string.Empty,
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var campagneEntity = mapper.Map<CampagneEntity>(campagne);
            await context.Campagnes.AddAsync(campagneEntity, cancellationToken);
            await context.SaveChangesAsync();

            return mapper.Map<Campagne>(campagneEntity);
        }
    }

    public static async Task<ImageMetaData> CreateIamgeMetaDataInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        User userOfImage,
        Campagne campagneForImage,
        CancellationToken cancellationToken = default
    )
    {
        var imageMetaData = new ImageMetaData
        {
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            ApiKey = "12345678909765431",
            CreatedForCampagneId = campagneForImage.Id,
            CreatorId = userOfImage.Id,
            ImageType = ImageType.PNG,
            LocallyStored = true,
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var imageMetaDataEntity = mapper.Map<ImageMetaDataEntity>(imageMetaData);
            await context.imageMetaDatas.AddAsync(imageMetaDataEntity, cancellationToken);
            await context.SaveChangesAsync();

            return mapper.Map<ImageMetaData>(imageMetaDataEntity);
        }
    }

    public static async Task<User> CreateUserInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default,
        string? signInProviderId = null,
        string? usernameOverride = null
    )
    {
        var user = new User
        {
            Username = usernameOverride ?? "User1",
            SignInProviderId = Option.From(signInProviderId),
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

    public static async Task<OpenSignInProviderRegisterRequest> CreateOpenSignInProviderRegisterRequestInDb(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var openSignInProviderRegisterRequest = new OpenSignInProviderRegisterRequest
        {
            CreationDate = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),
            LastModifiedAt = new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero),

            Email = "asdf@asdf.apple.de",
            ExposedApiKey = "sdfghjklkjhgfd",
            IdentityProviderId = "270c17fb-5cc5-470d-b5c5-72a2766d5665",
            SignInProviderRefreshToken = "hjvablsdkjfhalksdhf",
            SignInProviderUsed = SupportedSignInProviders.Apple,
        };

        using (var context = contextFactory.CreateDbContext())
        {
            var registerEntity = mapper.Map<OpenSignInProviderRegisterRequestEntity>(openSignInProviderRegisterRequest);
            await context.OpenSignInProviderRegisterRequests.AddAsync(registerEntity, cancellationToken);

            await context.SaveChangesAsync();
            return mapper.Map<OpenSignInProviderRegisterRequest>(registerEntity);
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
        CancellationToken cancellationToken = default,
        string? email = null,
        string? passwordResetToken = null,
        DateTimeOffset? passwordResetTokenExpireDate = null,
        bool? signInProvider = null
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
            Email = email ?? "asdf@asdf.de",
            Deleted = false,
            EncryptionChallengeId = encryptionChallenge.Id,
            HashedPassword = "asdfhjk",
            Id = UserCredential.UserCredentialIdentifier.From(Guid.Empty),
            PasswordResetToken = Option.From(passwordResetToken),
            PasswordResetTokenExpireDate = Option.From(passwordResetTokenExpireDate),
            RefreshToken = Option.None,
            SignInProvider = signInProvider ?? false,
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
