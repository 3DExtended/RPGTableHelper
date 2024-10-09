using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities;

namespace Prodot.Patterns.Cqrs.EfCore.Tests.TestHelpers.Context;

public class RpgDbContext : DbContext
{
    public RpgDbContext(DbContextOptions<RpgDbContext> options)
        : base(options) { }

    public DbSet<UserEntity> Entities { get; set; } = default!;
}
