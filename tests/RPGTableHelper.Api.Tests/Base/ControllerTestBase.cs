using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Base;

public abstract class ControllerTestBase
    : IClassFixture<WebApplicationFactory<Program>>,
        IDisposable
{
    protected readonly HttpClient _client;
    protected readonly WebApplicationFactory<Program> _factory;
    protected RpgDbContext? Context { get; private set; }

    protected IDbContextFactory<RpgDbContext>? ContextFactory { get; private set; }
    private bool _isDisposed;
    private string _runIdentifier;

    public ControllerTestBase(WebApplicationFactory<Program> factory)
    {
        _runIdentifier = Guid.NewGuid().ToString();

        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Development");

            builder.ConfigureServices(services =>
            {
                // Remove the app's database context registration
                var dbContextDescriptor = services.SingleOrDefault(d =>
                    d.ServiceType == typeof(DbContextOptions<RpgDbContext>)
                );

                if (dbContextDescriptor != null)
                {
                    services.Remove(dbContextDescriptor);
                }

                // Remove the app's database context registration
                var dbContextFactoryDescriptor = services.SingleOrDefault(d =>
                    d.ServiceType == typeof(IDbContextFactory<RpgDbContext>)
                );

                if (dbContextFactoryDescriptor != null)
                {
                    services.Remove(dbContextFactoryDescriptor);
                }

                // Add a database context using an in-memory SQLite database
                services.AddDbContextFactory<RpgDbContext>(options =>
                {
                    options.UseSqlite(
                        $"DataSource=file:memdbapi{_runIdentifier}?mode=memory&cache=shared"
                    );
                });

                // Build the service provider
                var sp = services.BuildServiceProvider();

                // Create a scope to obtain a reference to the database context
                using (var scope = sp.CreateScope())
                {
                    var scopedServices = scope.ServiceProvider;
                    var db = scopedServices.GetRequiredService<RpgDbContext>();

                    ContextFactory = sp.GetRequiredService<IDbContextFactory<RpgDbContext>>();
                    Context = ContextFactory.CreateDbContext();
                    Context.Database.OpenConnection();
                    Context.Database.EnsureCreated();

                    // Ensure the database is created
                    db.Database.OpenConnection();
                    db.Database.EnsureCreated();
                }
            });
        });

        // Create HttpClient for making HTTP requests to the test server
        _client = _factory.CreateClient();
    }

    protected virtual void Dispose(bool disposing)
    {
        if (_isDisposed)
        {
            return;
        }

        if (disposing)
        {
            // free managed resources
            Context?.Database.CloseConnection();
            Context?.Dispose();
        }

        _isDisposed = true;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
}
