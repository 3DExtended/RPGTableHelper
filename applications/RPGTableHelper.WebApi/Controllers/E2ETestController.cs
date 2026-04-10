using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Controllers;

/// <summary>
/// Local E2E / integration-test helpers. Disabled outside the E2ETest environment.
/// </summary>
[ApiController]
[Route("e2e")]
public class E2ETestController : ControllerBase
{
    private const string SignalRTestUsername = "e2e_signalr_user";
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
}
