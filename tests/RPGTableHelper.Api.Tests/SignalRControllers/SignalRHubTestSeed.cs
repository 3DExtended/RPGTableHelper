using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

/// <summary>
/// Seeds a DM-owned campagne and a player character for two-user SignalR hub scenarios.
/// </summary>
public static class SignalRHubTestSeed
{
    public sealed class DmPlayerCampagneScenario
    {
        public User DmUser { get; init; } = default!;
        public User PlayerUser { get; init; } = default!;
        public Guid CampagneId { get; init; }
        public Guid PlayerCharacterId { get; init; }
    }

    public static async Task<DmPlayerCampagneScenario> SeedDmPlayerCampagneAsync(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var dm = await RpgDbContextHelpers.CreateUserInDb(
            contextFactory,
            mapper,
            cancellationToken,
            usernameOverride: "sr_hub_dm"
        );
        var player = await RpgDbContextHelpers.CreateUserInDb(
            contextFactory,
            mapper,
            cancellationToken,
            usernameOverride: "sr_hub_player"
        );

        var campagne = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "SignalRHubTest",
            DmUserId = dm.Id.Value,
            JoinCode = "777-888",
            RpgConfiguration = "{}",
        };

        await using (var ctx = await contextFactory.CreateDbContextAsync(cancellationToken))
        {
            await ctx.Campagnes.AddAsync(campagne, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        var character = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = campagne.Id,
            CharacterName = "SignalRHero",
            PlayerUserId = player.Id.Value,
            RpgCharacterConfiguration = "{}",
        };

        await using (var ctx = await contextFactory.CreateDbContextAsync(cancellationToken))
        {
            await ctx.PlayerCharacters.AddAsync(character, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        return new DmPlayerCampagneScenario
        {
            DmUser = dm,
            PlayerUser = player,
            CampagneId = campagne.Id,
            PlayerCharacterId = character.Id,
        };
    }

    /// <summary>
    /// One DM, two distinct player users, one campagne, two player characters (same campagne).
    /// </summary>
    public sealed class DmTwoPlayersCampagneScenario
    {
        public User DmUser { get; init; } = default!;
        public User PlayerOneUser { get; init; } = default!;
        public User PlayerTwoUser { get; init; } = default!;
        public Guid CampagneId { get; init; }
        public Guid PlayerOneCharacterId { get; init; }
        public Guid PlayerTwoCharacterId { get; init; }
    }

    public static async Task<DmTwoPlayersCampagneScenario> SeedDmTwoPlayersCampagneAsync(
        IDbContextFactory<RpgDbContext> contextFactory,
        IMapper mapper,
        CancellationToken cancellationToken = default
    )
    {
        var dm = await RpgDbContextHelpers.CreateUserInDb(
            contextFactory,
            mapper,
            cancellationToken,
            usernameOverride: "sr_2p_dm"
        );
        var playerOne = await RpgDbContextHelpers.CreateUserInDb(
            contextFactory,
            mapper,
            cancellationToken,
            usernameOverride: "sr_2p_player_a"
        );
        var playerTwo = await RpgDbContextHelpers.CreateUserInDb(
            contextFactory,
            mapper,
            cancellationToken,
            usernameOverride: "sr_2p_player_b"
        );

        var campagne = new CampagneEntity
        {
            Id = Guid.Empty,
            CampagneName = "SignalRHubTestTwoPlayers",
            DmUserId = dm.Id.Value,
            JoinCode = "888-999",
            RpgConfiguration = "{}",
        };

        await using (var ctx = await contextFactory.CreateDbContextAsync(cancellationToken))
        {
            await ctx.Campagnes.AddAsync(campagne, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        var characterOne = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = campagne.Id,
            CharacterName = "HeroA",
            PlayerUserId = playerOne.Id.Value,
            RpgCharacterConfiguration = "{}",
        };

        var characterTwo = new PlayerCharacterEntity
        {
            Id = Guid.Empty,
            CampagneId = campagne.Id,
            CharacterName = "HeroB",
            PlayerUserId = playerTwo.Id.Value,
            RpgCharacterConfiguration = "{}",
        };

        await using (var ctx = await contextFactory.CreateDbContextAsync(cancellationToken))
        {
            await ctx.PlayerCharacters.AddAsync(characterOne, cancellationToken);
            await ctx.PlayerCharacters.AddAsync(characterTwo, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        return new DmTwoPlayersCampagneScenario
        {
            DmUser = dm,
            PlayerOneUser = playerOne,
            PlayerTwoUser = playerTwo,
            CampagneId = campagne.Id,
            PlayerOneCharacterId = characterOne.Id,
            PlayerTwoCharacterId = characterTwo.Id,
        };
    }
}
