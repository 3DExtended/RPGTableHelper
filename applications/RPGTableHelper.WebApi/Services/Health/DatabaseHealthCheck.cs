using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;

using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.WebApi.Services.Health;

/// <summary>
/// Healthy when the API can read its SQLite database; unhealthy when the file is gone, cannot be read as a database,
/// or does not answer within <see cref="ProbeTimeout"/>. It only reads: on SQLite, EF's CanConnect looks for the file
/// and never creates it, and the one query reads the schema table, which also proves the file is a database.
/// </summary>
public sealed class DatabaseHealthCheck : IHealthCheck
{
    public const string Name = "database";

    /// <summary>
    /// Well inside the 10 s the uptime check waits for an answer.
    /// </summary>
    public static readonly TimeSpan ProbeTimeout = TimeSpan.FromSeconds(3);

    private const string SchemaQuery = "SELECT count(*) AS \"Value\" FROM sqlite_master";

    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public DatabaseHealthCheck(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default
    )
    {
        // Microsoft.Data.Sqlite works synchronously and sleeps through a locked file for up to its command timeout
        // without looking at the token, so the probe gets its own task and the answer stops waiting for it in time.
        // A timeout (TimeoutException) or a database error is reported as unhealthy by the health check service.
        var probe = Task.Run(() => CanReadDatabaseAsync(cancellationToken), cancellationToken);
        var canRead = await probe.WaitAsync(ProbeTimeout, cancellationToken).ConfigureAwait(false);

        return canRead ? HealthCheckResult.Healthy() : HealthCheckResult.Unhealthy("The database file does not exist.");
    }

    private async Task<bool> CanReadDatabaseAsync(CancellationToken cancellationToken)
    {
        await using var dbContext = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);
        dbContext.Database.SetCommandTimeout(ProbeTimeout);

        if (!await dbContext.Database.CanConnectAsync(cancellationToken).ConfigureAwait(false))
        {
            return false;
        }

        await dbContext.Database.SqlQueryRaw<long>(SchemaQuery).SingleAsync(cancellationToken).ConfigureAwait(false);
        return true;
    }
}
