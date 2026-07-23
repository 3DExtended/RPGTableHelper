using FluentAssertions;

using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.Extensions.DependencyInjection;

using NSubstitute;

using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.Tests.Migrations;

/// <summary>
/// Verifies that the sse-02 config revision history migration lands cleanly on top of an existing (pre-history)
/// database, and that campagnes created before this migration remain fully loadable afterwards.
/// </summary>
public class ConfigRevisionHistoryMigrationTests
{
    private const string PreviousMigrationId = "20260414055930_AddRpgConfigurationMergedRevision";

    [Fact]
    public async Task Migrate_ShouldAddHistoryTables_WhileKeepingPreExistingCampagneDataLoadable()
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

            // Simulate a deployment that already ran every migration up to (but not including) this slice's migration.
            await migrator.MigrateAsync(PreviousMigrationId);

            var dmUser = new UserEntity { Username = "PreExistingDm" };
            await context.Users.AddAsync(dmUser);
            await context.SaveChangesAsync();

            var preExistingCampagne = new CampagneEntity
            {
                CampagneName = "PreExistingCampagne",
                JoinCode = "OLDJOIN",
                DmUserId = dmUser.Id,
                RpgConfiguration = "{\"rpgName\":\"legacy\"}",
                RpgConfigurationCold = "{\"allItems\":[]}",
                RpgConfigurationHot = "{\"rpgName\":\"legacy\"}",
                RpgConfigurationSchemaVersion = 1,
                RpgConfigurationColdRevision = 3,
                RpgConfigurationHotRevision = 4,
                RpgConfigurationMergedRevision = 7,
            };
            await context.Campagnes.AddAsync(preExistingCampagne);
            await context.SaveChangesAsync();
            var preExistingCampagneId = preExistingCampagne.Id;

            // act: bring the database up to the latest migration (including this slice's history tables).
            await migrator.MigrateAsync();

            // assert
            var reloaded = await context.Campagnes.AsNoTracking().SingleAsync(c => c.Id == preExistingCampagneId);
            reloaded.CampagneName.Should().Be("PreExistingCampagne");
            reloaded.RpgConfiguration.Should().Be("{\"rpgName\":\"legacy\"}");
            reloaded.RpgConfigurationCold.Should().Be("{\"allItems\":[]}");
            reloaded.RpgConfigurationHot.Should().Be("{\"rpgName\":\"legacy\"}");
            reloaded.RpgConfigurationColdRevision.Should().Be(3);
            reloaded.RpgConfigurationHotRevision.Should().Be(4);
            reloaded.RpgConfigurationMergedRevision.Should().Be(7);

            // new history tables exist and are empty for pre-existing data (no snapshots were ever recorded for it).
            (await context.CampagneRpgConfigHistories.CountAsync()).Should().Be(0);
            (await context.PlayerCharacterRpgConfigHistories.CountAsync()).Should().Be(0);

            // new tables accept writes as expected going forward.
            await context.CampagneRpgConfigHistories.AddAsync(
                new CampagneRpgConfigHistoryEntity
                {
                    CampagneId = preExistingCampagneId,
                    Revision = 7,
                    ConfigJson = reloaded.RpgConfiguration!,
                }
            );
            await context.SaveChangesAsync();

            (await context.CampagneRpgConfigHistories.CountAsync(h => h.CampagneId == preExistingCampagneId)).Should().Be(1);
        }
        finally
        {
            await connection.CloseAsync();
        }
    }
}
