using System.Collections.Concurrent;
using System.Data.Common;
using System.Net;

using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Hosting.Server.Features;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;

using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Health;

/// <summary>
/// The API the way the container runs it (environment Development, docker-compose.yml) on its own SQLite file,
/// with every database command and every log line it writes recorded.
/// </summary>
internal sealed class HealthTestHost : IAsyncDisposable
{
    /// <summary>
    /// The host the uptime check asks for; cloudflared hands it on to the container over plain http.
    /// </summary>
    public const string PublicHost = "questkeeper-prod.peter-esser.de";

    private readonly WebApplicationFactory<Program> _rootFactory;
    private readonly WebApplicationFactory<Program> _factory;
    private readonly string _directory;
    private readonly bool _usesKestrel;

    private HealthTestHost(Action<IServiceCollection>? configureServices, bool useKestrel)
    {
        _directory = Path.Combine(Path.GetTempPath(), "rpgtablehelper-health-tests", Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(_directory);
        DatabasePath = Path.Combine(_directory, "maindb2.db");
        _usesKestrel = useKestrel;

        _rootFactory = new WebApplicationFactory<Program>();
        _factory = _rootFactory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Development");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                // Development loads user secrets; these tests must not depend on the machine they run on.
                foreach (var secrets in config.Sources.OfType<JsonConfigurationSource>()
                    .Where(source => source.Path?.Contains("secrets.json") == true)
                    .ToList())
                {
                    config.Sources.Remove(secrets);
                }

                // Development validates every registration at startup, so the options prod gets from its
                // environment need a stand-in. None of them is read by /health.
                config.AddInMemoryCollection(
                    new Dictionary<string, string?>
                    {
                        ["Jwt:Issuer"] = "api",
                        ["Jwt:Audience"] = "api",
                        ["Jwt:Key"] = "unused",
                        ["SendGrid:IsDisabled"] = "true",
                        ["RSA:PrivateRsaKeyAsPEM"] = "unused",
                        ["RSA:PublicRsaKeyAsPEM"] = "unused",
                        ["Apple:ClientId"] = "unused",
                    }
                );
            });
            builder.ConfigureLogging(logging => logging.AddProvider(Logs));
            builder.ConfigureServices(services =>
            {
                services.RemoveAll<DbContextOptions<RpgDbContext>>();
                services.RemoveAll<IDbContextFactory<RpgDbContext>>();
                services.RemoveAll<IDbContextOptionsConfiguration<RpgDbContext>>();
                services.AddDbContextFactory<RpgDbContext>(options =>
                    options.UseSqlite(ConnectionString).AddInterceptors(Commands)
                );

                configureServices?.Invoke(services);
            });
        });

        if (useKestrel)
        {
            // Plain http only, like the container (Program.cs binds http://*:5012 and nothing else); a free
            // loopback port so the test never collides with an API running on this machine.
            _factory.UseKestrel(options => options.Listen(IPAddress.Loopback, 0));
        }

        // Starting runs the migrations on the empty file, as the container does on every start.
        _factory.StartServer();
        Commands.Clear();
        Logs.Clear();
    }

    public string DatabasePath { get; }

    public RecordingCommandInterceptor Commands { get; } = new();

    public CapturingLoggerProvider Logs { get; } = new();

    private string ConnectionString => $"Data Source={DatabasePath}";

    public static HealthTestHost Start(Action<IServiceCollection>? configureServices = null) =>
        new(configureServices, useKestrel: false);

    /// <summary>
    /// Runs the API on a real Kestrel socket over plain http, like the container behind the tunnel.
    /// </summary>
    public static HealthTestHost StartOnKestrel() => new(configureServices: null, useKestrel: true);

    /// <summary>
    /// A client that, like the uptime check, never follows a redirect and gives up long before a test would hang.
    /// </summary>
    public HttpClient CreateClient()
    {
        if (!_usesKestrel)
        {
            var client = _factory.CreateClient(
                new WebApplicationFactoryClientOptions
                {
                    AllowAutoRedirect = false,
                    BaseAddress = new Uri($"http://{PublicHost}"),
                    HandleCookies = false,
                }
            );
            client.Timeout = TimeSpan.FromSeconds(15);
            return client;
        }

        var address = _factory.Services.GetRequiredService<IServer>()
            .Features.Get<IServerAddressesFeature>()!
            .Addresses.Single();

        return new HttpClient(new SocketsHttpHandler { AllowAutoRedirect = false, UseCookies = false })
        {
            BaseAddress = new Uri(address),
            Timeout = TimeSpan.FromSeconds(15),
        };
    }

    /// <summary>
    /// Takes the database file away, as an unmounted volume would.
    /// </summary>
    public void DeleteDatabaseFile()
    {
        CloseDatabaseConnections();
        foreach (var file in Directory.GetFiles(_directory, "maindb2.db*"))
        {
            File.Delete(file);
        }
    }

    /// <summary>
    /// Leaves an empty file where the database was, as a volume that lost its contents would. SQLite reads an empty
    /// file as an empty database.
    /// </summary>
    public void EmptyDatabaseFile()
    {
        DeleteDatabaseFile();
        File.WriteAllBytes(DatabasePath, []);
    }

    /// <summary>
    /// Holds an exclusive lock on the database until disposed, the way a long write from elsewhere would. Under the
    /// rollback journal a reader then gets SQLITE_BUSY and retries until its command timeout.
    /// </summary>
    public IDisposable LockDatabase()
    {
        CloseDatabaseConnections();
        var connection = new SqliteConnection($"{ConnectionString};Pooling=False");
        connection.Open();
        using var command = connection.CreateCommand();
        command.CommandText = "PRAGMA journal_mode=DELETE; BEGIN EXCLUSIVE;";
        command.ExecuteNonQuery();
        return connection;
    }

    /// <summary>
    /// Leaves a file in place that SQLite cannot read as a database.
    /// </summary>
    public void OverwriteDatabaseFileWithGarbage()
    {
        CloseDatabaseConnections();
        File.WriteAllText(DatabasePath, new string('x', 8192));
    }

    public async ValueTask DisposeAsync()
    {
        Commands.Release();
        await _factory.DisposeAsync();
        await _rootFactory.DisposeAsync();
        CloseDatabaseConnections();

        try
        {
            Directory.Delete(_directory, recursive: true);
        }
        catch (IOException)
        {
            // A probe the health check left behind may still hold the file for a moment; it is a temp folder.
        }
    }

    private void CloseDatabaseConnections()
    {
        using var connection = new SqliteConnection(ConnectionString);
        SqliteConnection.ClearPool(connection);
    }
}

/// <summary>
/// Records the SQL the API runs and, after <see cref="Hang"/>, blocks every command synchronously the way SQLite
/// blocks on a locked or stuck file, until <see cref="Release"/>.
/// </summary>
internal sealed class RecordingCommandInterceptor : DbCommandInterceptor
{
    private readonly ConcurrentQueue<string> _executed = new();
    private readonly ManualResetEventSlim _running = new(initialState: true);

    public IReadOnlyCollection<string> Executed => _executed.ToArray();

    public void Clear() => _executed.Clear();

    public void Hang() => _running.Reset();

    public void Release() => _running.Set();

    public override InterceptionResult<DbDataReader> ReaderExecuting(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<DbDataReader> result
    )
    {
        Run(command);
        return result;
    }

    public override ValueTask<InterceptionResult<DbDataReader>> ReaderExecutingAsync(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<DbDataReader> result,
        CancellationToken cancellationToken = default
    )
    {
        Run(command);
        return ValueTask.FromResult(result);
    }

    public override InterceptionResult<int> NonQueryExecuting(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<int> result
    )
    {
        Run(command);
        return result;
    }

    public override ValueTask<InterceptionResult<int>> NonQueryExecutingAsync(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default
    )
    {
        Run(command);
        return ValueTask.FromResult(result);
    }

    public override InterceptionResult<object> ScalarExecuting(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<object> result
    )
    {
        Run(command);
        return result;
    }

    public override ValueTask<InterceptionResult<object>> ScalarExecutingAsync(
        DbCommand command,
        CommandEventData eventData,
        InterceptionResult<object> result,
        CancellationToken cancellationToken = default
    )
    {
        Run(command);
        return ValueTask.FromResult(result);
    }

    private void Run(DbCommand command)
    {
        _executed.Enqueue(command.CommandText);

        // Deliberately ignores cancellation: a stuck SQLite call does not look at the token either.
        _running.Wait(TimeSpan.FromSeconds(30));
    }
}

/// <summary>
/// Keeps every log entry that passes the app's own log level configuration.
/// </summary>
internal sealed class CapturingLoggerProvider : ILoggerProvider
{
    private readonly ConcurrentQueue<CapturedLogEntry> _entries = new();

    public IReadOnlyCollection<CapturedLogEntry> Entries => _entries.ToArray();

    public void Clear() => _entries.Clear();

    public ILogger CreateLogger(string categoryName) => new CapturingLogger(categoryName, _entries);

    public void Dispose()
    {
        // Nothing to release.
    }

    private sealed class CapturingLogger : ILogger
    {
        private readonly string _category;
        private readonly ConcurrentQueue<CapturedLogEntry> _entries;

        public CapturingLogger(string category, ConcurrentQueue<CapturedLogEntry> entries)
        {
            _category = category;
            _entries = entries;
        }

        public IDisposable? BeginScope<TState>(TState state)
            where TState : notnull => null;

        public bool IsEnabled(LogLevel logLevel) => logLevel != LogLevel.None;

        public void Log<TState>(
            LogLevel logLevel,
            EventId eventId,
            TState state,
            Exception? exception,
            Func<TState, Exception?, string> formatter
        )
        {
            _entries.Enqueue(new CapturedLogEntry(_category, logLevel, formatter(state, exception), exception));
        }
    }
}

internal sealed class CapturedLogEntry
{
    public CapturedLogEntry(string category, LogLevel level, string message, Exception? exception)
    {
        Category = category;
        Level = level;
        Message = message;
        Exception = exception;
    }

    public string Category { get; }

    public Exception? Exception { get; }

    public LogLevel Level { get; }

    public string Message { get; }
}
