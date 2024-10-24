using System.Net;
using System.Net.Http.Headers;
using AutoMapper;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.SendGrid.Options;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.Shared.Options;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Options;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.Api.Tests.Base;

public abstract class ControllerTestBase : IClassFixture<WebApplicationFactory<Program>>, IDisposable
{
    protected HttpClient Client { get; }
    protected WebApplicationFactory<Program> Factory { get; }

    protected IServiceProvider ServiceProvider { get; private set; } = default!;
    protected ISystemClock SystemClock { get; private set; } = default!;
    protected IQueryProcessor QueryProcessor { get; private set; } = default!;
    protected IJWTTokenGenerator JwtTokenGenerator { get; private set; } = default!;
    protected RpgDbContext Context { get; private set; } = default!;
    protected IMapper Mapper { get; private set; } = default!;

    protected IDbContextFactory<RpgDbContext> ContextFactory { get; private set; } = default!;
    private readonly string _runIdentifier;
    private bool _isDisposed;

    protected ControllerTestBase(WebApplicationFactory<Program> factory)
    {
        _runIdentifier = Guid.NewGuid().ToString();

        Factory = factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("E2ETest");

            builder.ConfigureServices(services =>
            {
                ReconfigureDatabase(services);
                ReconfigureOptions(services);

                // Build the service provider
                ServiceProvider = services.BuildServiceProvider();
                Mapper = ServiceProvider.GetRequiredService<IMapper>();

                QueryProcessor = ServiceProvider.GetRequiredService<IQueryProcessor>();
                JwtTokenGenerator = ServiceProvider.GetRequiredService<IJWTTokenGenerator>();
                SystemClock = ServiceProvider.GetRequiredService<ISystemClock>();
                ContextFactory = ServiceProvider.GetRequiredService<IDbContextFactory<RpgDbContext>>();
                Context = ContextFactory.CreateDbContext();
                Context.Database.OpenConnection();
                Context.Database.EnsureCreated();

                // Create a scope to obtain a reference to the database context
                using (var scope = ServiceProvider.CreateScope())
                {
                    var scopedServices = scope.ServiceProvider;

                    // Ensure the database is created
                    var db = scopedServices.GetRequiredService<RpgDbContext>();
                    db.Database.OpenConnection();
                    db.Database.EnsureCreated();
                }
            });
        });

        // Create HttpClient for making HTTP requests to the test server
        Client = Factory.CreateClient();
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
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

    protected async Task<User> ConfigureLoggedInUser()
    {
        // arrange
        var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);

        var jwtOptions = new JwtOptions
        {
            Issuer = "api",
            Audience = "api",
            Key = string.Join(string.Empty, Enumerable.Repeat("asdfasdf", 200)),
            NumberOfSecondsToExpire = 12000,
        };

        var tokenGenerator = new JWTTokenGenerator(SystemClock, jwtOptions);

        var jwt = tokenGenerator.GetJWTToken(user.Username, user.Id.Value.ToString());
        Client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwt!);

        // act
        var response = await Client.GetAsync("/SignIn/testlogin");

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        return user!;
    }

    private static void ReconfigureOptions(IServiceCollection services)
    {
        var sendGridOptionDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(SendGridOptions));

        if (sendGridOptionDescriptor != null)
        {
            services.Remove(sendGridOptionDescriptor);
        }

        services.AddSingleton(
            new SendGridOptions
            {
                ApiKey = "ichbineinkey",
                FromEmailAddress = "asdf@asdf.de",
                FromSenderName = "Asdf",
                IsDisabled = true,
            }
        );

        var rsaOptionDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(RSAOptions));

        if (rsaOptionDescriptor != null)
        {
            services.Remove(rsaOptionDescriptor);
        }

        // Add random rsa pem key for tesing. DO NOT USE IN PROD!
        services.AddSingleton(
            new RSAOptions
            {
                PrivateRsaKeyAsPEM =
                    "-----BEGIN RSA PRIVATE KEY-----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-----END RSA PRIVATE KEY-----",
                PublicRsaKeyAsPEM =
                    "-----BEGIN PUBLIC KEY-----MIICITANBgkqhkiG9w0BAQEFAAOCAg4AMIICCQKCAgB+rw62GbgkC8l+K9+Ctb3kJf3mT80fx1Ub6q2mBnZn9rjjuqz97rPbO8xedXexaPP5JZNAbw9tWwNGuuIdvCNt898epjjLbHGWcGErXT819HPfmzTllDYpoyTLB231WUeVfgujcVViE8GlCrjgd/+pRyLcZ7J7g/ynueX8Zi2nu6TKLwQkUUQlPlvi1ea2S9YKy+zjyNK2gaeLaW4YXOHjOc4LgNZN9XP70nX+YD28H+FhifXpkMwYx94z7wKbJ5uWxvHGWdB4lRZb6xokNXLs+43pRUCJEEoBrz1ME5dkdfchuiTgvx/TJaYIn27/xNvZvIPm0zvbwoLRYWyeZ5qywxDehyK0ce6njXtSy+b7Ly9NEHh/5TaiNJF2pmbSSDlANADibr7JfAK3fuQrx99GB9XmZSh+sTnao1P83x0PJoG6CEgvjMAL3mA8f3iL94xQE91YIcxNZ3+dflbGxW04Kxf1kqYy9GKO/vYNnc/VtfvvfH5Eg6t/goG7NaCom6OQ4eE459kjPCjMlr93IGPx3LH0ilUTvub/QZiboBMQBIHYewamIw3pTgJ2oCdnMgHaW9nIVA20ec65Zm0t8BaKbRwigSVSmkfDFL+OQxZZ1E+3OP3KiijPkVkS9BhIwEkR21/i573GrDx/WziHHAwxDRvcf23Sah6AL/Bp6JWF6wIDAQAB-----END PUBLIC KEY-----",
            }
        );

        var jwtOptionDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(JwtOptions));

        if (jwtOptionDescriptor != null)
        {
            services.Remove(jwtOptionDescriptor);
        }

        // Add random rsa pem key for tesing. DO NOT USE IN PROD!
        services.AddSingleton(
            new JwtOptions
            {
                Issuer = "api",
                Audience = "api",
                Key = string.Join(string.Empty, Enumerable.Repeat("asdfasdf", 200)),
                NumberOfSecondsToExpire = 12000,
            }
        );

        var appleOptionDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(AppleAuthOptions));

        if (appleOptionDescriptor != null)
        {
            services.Remove(appleOptionDescriptor);
        }

        // Add random rsa pem key for tesing. DO NOT USE IN PROD!
        services.AddSingleton(
            new AppleAuthOptions
            {
                ClientId = "clientidapple",
                ClientSecretExpiresAfterHours = 2,
                Key = "applekey",
                KeyId = "applekeykd",
                TeamId = "teamid",
            }
        );
    }

    private void ReconfigureDatabase(IServiceCollection services)
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
            options.UseSqlite($"DataSource=file:memdbapi{_runIdentifier}?mode=memory&cache=shared");
        });
    }
}
