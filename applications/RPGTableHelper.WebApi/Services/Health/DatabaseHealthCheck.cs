using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.Diagnostics.HealthChecks;

using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services.Health;

/// <summary>
/// Healthy when the API can read its SQLite database and the database holds the app's schema (the migrations
/// history table the startup migrations write); unhealthy when the file is gone, empty, cannot be read as a database,
/// or does not answer in time. It only reads: on SQLite, EF's CanConnect looks for the file and never creates it, and
/// the one query reads the schema table.
/// </summary>
public sealed class DatabaseHealthCheck : IHealthCheck
{
    public const string Name = "database";

    private const string SchemaQuery =
        "SELECT count(*) AS \"Value\" FROM sqlite_master WHERE type = 'table' AND name = '"
        + HistoryRepository.DefaultTableName
        + "'";

    /// <summary>
    /// How long SQLite retries a locked file before the probe gives up on its own, with SQLite's reason.
    /// </summary>
    private static readonly TimeSpan CommandTimeout = TimeSpan.FromSeconds(2);

    /// <summary>
    /// When the answer stops waiting for a probe that ignores the command timeout too (a stuck read); well inside
    /// the 10 s the uptime check waits.
    /// </summary>
    private static readonly TimeSpan AnswerTimeout = TimeSpan.FromSeconds(3);

    private readonly DbContextOptions<RpgDbContext> _probeOptions;
    private readonly ISystemClock _systemClock;

    public DatabaseHealthCheck(DbContextOptions<RpgDbContext> options, ISystemClock systemClock)
    {
        // The health check service logs a failed check once, with its reason. EF's own error events for the same
        // failure would add two more entries with a stack trace each, every minute the database is down.
        _probeOptions = new DbContextOptionsBuilder<RpgDbContext>(options)
            .ConfigureWarnings(warnings =>
                warnings.Log(
                    (RelationalEventId.ConnectionError, LogLevel.Debug),
                    (RelationalEventId.CommandError, LogLevel.Debug),
                    (CoreEventId.QueryIterationFailed, LogLevel.Debug)
                )
            )
            .Options;
        _systemClock = systemClock;
    }

    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default
    )
    {
        // Microsoft.Data.Sqlite works synchronously and does not look at the token while it reads, so the probe gets
        // its own task, and a read stuck past AnswerTimeout is reported as unhealthy (TimeoutException) without
        // waiting for it. A thrown database error is reported as unhealthy by the health check service too.
        var probe = Task.Run(() => ProbeAsync(cancellationToken), cancellationToken);
        return probe.WaitAsync(AnswerTimeout, cancellationToken);
    }

    private async Task<HealthCheckResult> ProbeAsync(CancellationToken cancellationToken)
    {
        await using var dbContext = new RpgDbContext(_systemClock, _probeOptions);
        dbContext.Database.SetCommandTimeout(CommandTimeout);

        if (!await dbContext.Database.CanConnectAsync(cancellationToken).ConfigureAwait(false))
        {
            return HealthCheckResult.Unhealthy("The database file does not exist.");
        }

        var schemaTables = await dbContext
            .Database.SqlQueryRaw<long>(SchemaQuery)
            .SingleAsync(cancellationToken)
            .ConfigureAwait(false);

        return schemaTables > 0
            ? HealthCheckResult.Healthy()
            : HealthCheckResult.Unhealthy("The database holds no schema.");
    }
}
