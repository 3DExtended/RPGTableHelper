using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace Prodot.Patterns.Cqrs.EfCore.Tests.TestHelpers.Context;

public class RpgDbContext : DbContext
{
    public RpgDbContext(DbContextOptions<RpgDbContext> options)
        : base(options) { }

    public DbSet<UserEntity> Users { get; set; } = default!;
    public DbSet<EncryptionChallengeEntity> EncryptionChallenges { get; set; } = default!;
}
