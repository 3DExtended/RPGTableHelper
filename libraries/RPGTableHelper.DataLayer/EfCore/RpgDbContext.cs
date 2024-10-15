using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.EfCore;

public class RpgDbContext : DbContext
{
    public RpgDbContext(DbContextOptions<RpgDbContext> options)
        : base(options) { }

    public DbSet<UserEntity> Users { get; set; } = default!;
    public DbSet<UserCredentialEntity> UserCredentials { get; set; } = default!;
    public DbSet<EncryptionChallengeEntity> EncryptionChallenges { get; set; } = default!;
}
