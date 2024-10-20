using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.EfCore;

public class RpgDbContext : DbContext
{
    public RpgDbContext(DbContextOptions<RpgDbContext> options)
        : base(options) { }

    public DbSet<CampagneEntity> Campagnes { get; set; } = default!;
    public DbSet<PlayerCharacterEntity> PlayerCharacters { get; set; } = default!;

    public DbSet<UserEntity> Users { get; set; } = default!;
    public DbSet<UserCredentialEntity> UserCredentials { get; set; } = default!;
    public DbSet<EncryptionChallengeEntity> EncryptionChallenges { get; set; } = default!;

    public DbSet<OpenSignInProviderRegisterRequestEntity> OpenSignInProviderRegisterRequests { get; set; } =
        default!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .Entity<CampagneEntity>()
            .HasMany(e => e.Characters)
            .WithOne(e => e.Campagne)
            .HasForeignKey(e => e.CampagneId);

        base.OnModelCreating(modelBuilder);
    }
}
