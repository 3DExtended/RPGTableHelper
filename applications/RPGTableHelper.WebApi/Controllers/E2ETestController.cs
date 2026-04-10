using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.E2E;

namespace RPGTableHelper.WebApi.Controllers;

/// <summary>
/// Local E2E / integration-test helpers. Disabled outside the E2ETest environment.
/// </summary>
[ApiController]
[Route("e2e")]
public class E2ETestController : ControllerBase
{
    private const string SignalRTestUsername = "e2e_signalr_user";

    private const string MultiDmUsername = "e2e_multi_dm";
    private const string MultiP1Username = "e2e_multi_p1";
    private const string MultiP2Username = "e2e_multi_p2";
    private const string MultiCampagneJoinCode = "e2e-multi-777";
    private readonly IHostEnvironment _env;
    private readonly IDbContextFactory<RpgDbContext> _db;
    private readonly IJWTTokenGenerator _jwt;

    public E2ETestController(IHostEnvironment env, IDbContextFactory<RpgDbContext> db, IJWTTokenGenerator jwt)
    {
        _env = env;
        _db = db;
        _jwt = jwt;
    }

    /// <summary>
    /// Returns a valid JWT for an upserted test user (for Flutter integration_test against this API).
    /// Body is raw JWT text for simple clients.
    /// </summary>
    [HttpGet("signalr-test-jwt")]
    [AllowAnonymous]
    public async Task<IActionResult> GetSignalrTestJwtAsync(CancellationToken cancellationToken)
    {
        // E2ETest: xUnit in-memory host. LocalSignalRE2E: ./scripts/run_flutter_signalr_e2e.sh against local SQLite.
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        await using var ctx = await _db.CreateDbContextAsync(cancellationToken);
        var user = await ctx.Users.FirstOrDefaultAsync(u => u.Username == SignalRTestUsername, cancellationToken);
        if (user == null)
        {
            var now = DateTimeOffset.UtcNow;
            user = new UserEntity
            {
                Id = Guid.NewGuid(),
                Username = SignalRTestUsername,
                CreationDate = now,
                LastModifiedAt = now,
            };
            await ctx.Users.AddAsync(user, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        var token = _jwt.GetJWTToken(user.Username, user.Id.ToString());
        return Content(token, "text/plain");
    }

    /// <summary>
    /// Resets parallel multi-client coordination counters. Call once before launching multiple Flutter runners.
    /// </summary>
    [HttpPost("multi-client/reset")]
    [AllowAnonymous]
    public IActionResult ResetMultiClientCoordinator()
    {
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        E2EMultiClientCoordinator.Reset();
        return Ok();
    }

    /// <summary>
    /// Poll from Flutter: DM registration and player re-add counts for barrier-style sync.
    /// </summary>
    [HttpGet("multi-client/sync")]
    [AllowAnonymous]
    public IActionResult GetMultiClientSync()
    {
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        return Ok(
            new
            {
                dmGameRegistered = E2EMultiClientCoordinator.DmGameRegistered,
                playersReaddedCount = E2EMultiClientCoordinator.PlayersReaddedCount,
            }
        );
    }

    [HttpPost("multi-client/sync/dm-game-registered")]
    [AllowAnonymous]
    public IActionResult PostDmGameRegistered()
    {
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        E2EMultiClientCoordinator.MarkDmGameRegistered();
        return Ok();
    }

    [HttpPost("multi-client/sync/player-readded")]
    [AllowAnonymous]
    public IActionResult PostPlayerReadded()
    {
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        E2EMultiClientCoordinator.NotifyPlayerReadded();
        return Ok();
    }

    /// <summary>
    /// Seeds DM + two players + one campagne + two characters (idempotent) and returns JWT + ids for the requested role.
    /// </summary>
    [HttpGet("multi-client/session")]
    [AllowAnonymous]
    public async Task<IActionResult> GetMultiClientSessionAsync(
        [FromQuery] string role,
        CancellationToken cancellationToken
    )
    {
        if (!_env.IsEnvironment("E2ETest") && !_env.IsEnvironment("LocalSignalRE2E"))
        {
            return NotFound();
        }

        role = role.Trim().ToLowerInvariant();
        if (role is not ("dm" or "player1" or "player2"))
        {
            return BadRequest("role must be dm, player1, or player2");
        }

        var (dm, p1, p2, campagneId, char1, char2) = await EnsureMultiClientScenarioAsync(
            cancellationToken
        );

        UserEntity user = role switch
        {
            "dm" => dm,
            "player1" => p1,
            "player2" => p2,
            _ => throw new InvalidOperationException(),
        };

        Guid? characterId = role switch
        {
            "dm" => null,
            "player1" => char1,
            "player2" => char2,
            _ => null,
        };

        var token = _jwt.GetJWTToken(user.Username, user.Id.ToString());

        if (role == "dm")
        {
            return Ok(
                new
                {
                    jwt = token,
                    campagneId = campagneId.ToString(),
                    role,
                    userId = dm.Id.ToString(),
                    playerCharacterId = (string?)null,
                    player1UserId = p1.Id.ToString(),
                    player2UserId = p2.Id.ToString(),
                    player1CharacterId = char1.ToString(),
                    player2CharacterId = char2.ToString(),
                }
            );
        }

        return Ok(
            new
            {
                jwt = token,
                campagneId = campagneId.ToString(),
                role,
                userId = user.Id.ToString(),
                playerCharacterId = characterId?.ToString(),
            }
        );
    }

    private async Task<UserEntity> UpsertUserAsync(
        RpgDbContext ctx,
        string username,
        CancellationToken cancellationToken
    )
    {
        var user = await ctx.Users.FirstOrDefaultAsync(u => u.Username == username, cancellationToken);
        if (user != null)
        {
            return user;
        }

        var now = DateTimeOffset.UtcNow;
        user = new UserEntity
        {
            Id = Guid.NewGuid(),
            Username = username,
            CreationDate = now,
            LastModifiedAt = now,
        };
        await ctx.Users.AddAsync(user, cancellationToken);
        await ctx.SaveChangesAsync(cancellationToken);
        return user;
    }

    private async Task<(UserEntity Dm, UserEntity P1, UserEntity P2, Guid CampagneId, Guid Char1, Guid Char2)>
        EnsureMultiClientScenarioAsync(CancellationToken cancellationToken)
    {
        await using var ctx = await _db.CreateDbContextAsync(cancellationToken);

        var dm = await UpsertUserAsync(ctx, MultiDmUsername, cancellationToken);
        var p1 = await UpsertUserAsync(ctx, MultiP1Username, cancellationToken);
        var p2 = await UpsertUserAsync(ctx, MultiP2Username, cancellationToken);

        var campagne = await ctx.Campagnes.FirstOrDefaultAsync(
            c => c.DmUserId == dm.Id && c.JoinCode == MultiCampagneJoinCode,
            cancellationToken
        );

        if (campagne == null)
        {
            var now = DateTimeOffset.UtcNow;
            campagne = new CampagneEntity
            {
                Id = Guid.NewGuid(),
                CampagneName = "E2E Multi-Client",
                DmUserId = dm.Id,
                JoinCode = MultiCampagneJoinCode,
                RpgConfiguration = "{}",
                CreationDate = now,
                LastModifiedAt = now,
            };
            await ctx.Campagnes.AddAsync(campagne, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        var char1 = await ctx.PlayerCharacters.FirstOrDefaultAsync(
            pc => pc.CampagneId == campagne.Id && pc.PlayerUserId == p1.Id,
            cancellationToken
        );
        if (char1 == null)
        {
            var now = DateTimeOffset.UtcNow;
            char1 = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CampagneId = campagne.Id,
                CharacterName = "E2EMultiHero1",
                PlayerUserId = p1.Id,
                RpgCharacterConfiguration = "{}",
                CreationDate = now,
                LastModifiedAt = now,
            };
            await ctx.PlayerCharacters.AddAsync(char1, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        var char2 = await ctx.PlayerCharacters.FirstOrDefaultAsync(
            pc => pc.CampagneId == campagne.Id && pc.PlayerUserId == p2.Id,
            cancellationToken
        );
        if (char2 == null)
        {
            var now = DateTimeOffset.UtcNow;
            char2 = new PlayerCharacterEntity
            {
                Id = Guid.NewGuid(),
                CampagneId = campagne.Id,
                CharacterName = "E2EMultiHero2",
                PlayerUserId = p2.Id,
                RpgCharacterConfiguration = "{}",
                CreationDate = now,
                LastModifiedAt = now,
            };
            await ctx.PlayerCharacters.AddAsync(char2, cancellationToken);
            await ctx.SaveChangesAsync(cancellationToken);
        }

        return (dm, p1, p2, campagne.Id, char1.Id, char2.Id);
    }
}
