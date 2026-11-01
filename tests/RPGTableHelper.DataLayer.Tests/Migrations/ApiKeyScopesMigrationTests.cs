using FluentAssertions;

using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.DependencyInjection;

using NSubstitute;

using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.Tests.Migrations;

/// <summary>
/// API keys created before scopes existed must keep exactly the read-only access the external API offered
/// back then - and nothing more.
/// </summary>
public class ApiKeyScopesMigrationTests
{
    private const string PreviousMigrationId = "20260725221516_AddAuthSessions";

    [Fact]
    public async Task Migrate_ShouldGivePreExistingKeysTheLegacyReadScopes()
    {
        // arrange
        var connection = new SqliteConnection("DataSource=:memory:");
        await connection.OpenAsync();

        try
        {
            var systemClock = Substitute.For<ISystemClock>();
            systemClock.Now.Returns(new DateTimeOffset(2024, 10, 10, 10, 10, 10, TimeSpan.Zero));

            using var serviceProvider = new ServiceCollection()
                .AddDbContext<RpgDbContext>(o => o.UseSqlite(connection))
                .AddSingleton(systemClock)
                .BuildServiceProvider();

            using var context = serviceProvider.GetRequiredService<RpgDbContext>();
            var migrator = context.GetService<IMigrator>();

            await migrator.MigrateAsync(PreviousMigrationId);

            var user = new UserEntity { Username = "PreExistingKeyOwner" };
            await context.Users.AddAsync(user);
            await context.SaveChangesAsync();

            var keyId = Guid.NewGuid();

            // The entity already has the new columns, so the pre-migration row is written with raw SQL.
            await context.Database.ExecuteSqlRawAsync(
                "INSERT INTO \"ApiKeys\" (\"Id\", \"UserId\", \"Name\", \"KeyHash\", \"Prefix\", \"RevokedAt\", \"CreationDate\", \"LastModifiedAt\") "
                    + "VALUES ({0}, {1}, 'Old key', 'hash', 'sk-old1', NULL, '2024-10-10 10:10:10+00:00', '2024-10-10 10:10:10+00:00')",
                keyId.ToString().ToUpperInvariant(),
                user.Id.ToString().ToUpperInvariant()
            );

            // act
            await migrator.MigrateAsync();

            // assert
            var reloaded = await context.ApiKeys.AsNoTracking().SingleAsync();
            reloaded.Id.Should().Be(keyId);
            ApiKeyScopes.Parse(reloaded.Scopes).Should().BeEquivalentTo(ApiKeyScopes.LegacyDefault);
            reloaded.LastUsedAt.Should().BeNull();
            reloaded.ExpiresAt.Should().BeNull();
        }
        finally
        {
            await connection.CloseAsync();
        }
    }
}
