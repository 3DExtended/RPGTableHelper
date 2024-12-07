using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.Base;
using RPGTableHelper.DataLayer.Entities.Images;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.EfCore;

public class RpgDbContext : DbContext
{
    private readonly ISystemClock _systemClock;

    public RpgDbContext(ISystemClock systemClock, DbContextOptions<RpgDbContext> options)
        : base(options)
    {
        _systemClock = systemClock;
        SavingChanges += OnSavingChanges;
    }

    private void OnSavingChanges(object? sender, SavingChangesEventArgs e)
    {
        var now = _systemClock.Now;

        foreach (var entry in ChangeTracker.Entries<EntityBase<Guid>>())
        {
            if (entry.State is EntityState.Added)
            {
                entry.Entity.CreationDate = now;
            }

            if (entry.State is EntityState.Added or EntityState.Modified)
            {
                entry.Entity.LastModifiedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<EntityBase<int>>())
        {
            if (entry.State is EntityState.Added)
            {
                entry.Entity.CreationDate = now;
            }

            if (entry.State is EntityState.Added or EntityState.Modified)
            {
                entry.Entity.LastModifiedAt = now;
            }
        }
    }

    public DbSet<CampagneEntity> Campagnes { get; set; } = default!;
    public DbSet<PlayerCharacterEntity> PlayerCharacters { get; set; } = default!;
    public DbSet<UserEntity> Users { get; set; } = default!;
    public DbSet<NoteBlockEntityBase> NoteBlocks { get; set; } = default!;
    public DbSet<NoteDocumentEntity> CampagneDocuments { get; set; } = default!;
    public DbSet<PermittedUsersToNotesBlock> PermittedUsersToNotesBlocks { get; set; } = default!;
    public DbSet<UserCredentialEntity> UserCredentials { get; set; } = default!;
    public DbSet<EncryptionChallengeEntity> EncryptionChallenges { get; set; } = default!;
    public DbSet<ImageMetaDataEntity> imageMetaDatas { get; set; } = default!;
    public DbSet<CampagneJoinRequestEntity> CampagneJoinRequests { get; set; } = default!;
    public DbSet<OpenSignInProviderRegisterRequestEntity> OpenSignInProviderRegisterRequests { get; set; } = default!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // navigation between NoteDocumentEntity and NoteBlockEntityBase
        modelBuilder
            .Entity<NoteDocumentEntity>()
            .HasMany(e => e.NoteBlocks)
            .WithOne(e => e.NoteDocument)
            .HasForeignKey(e => e.NoteDocumentId)
            .IsRequired();

        // navigation between NoteBlockEntityBase and PermittedUsersToNotesBlock
        modelBuilder
            .Entity<NoteBlockEntityBase>()
            .HasMany(p => p.PermittedUsers)
            .WithOne(p => p.NotesBlock)
            .HasForeignKey(p => p.NotesBlockId);

        modelBuilder.Entity<NoteBlockEntityBase>().HasOne(e => e.CreatingUser);

        modelBuilder.Entity<NoteDocumentEntity>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<NoteBlockEntityBase>().HasQueryFilter(e => !e.IsDeleted);

        modelBuilder
            .Entity<CampagneEntity>()
            .HasMany(e => e.Characters)
            .WithOne(e => e.Campagne)
            .HasForeignKey(e => e.CampagneId);

        modelBuilder.Entity<CampagneEntity>().HasIndex(entity => entity.JoinCode).IsUnique();

        modelBuilder
            .Entity<CampagneJoinRequestEntity>()
            .HasIndex(entity => new { entity.CampagneId, entity.UserId })
            .IsUnique();

        modelBuilder
            .Entity<CampagneJoinRequestEntity>()
            .HasIndex(entity => new { entity.CampagneId, entity.PlayerId })
            .IsUnique();

        modelBuilder.Entity<UserEntity>().HasIndex(entity => entity.Username).IsUnique();
        modelBuilder.Entity<UserCredentialEntity>().HasIndex(entity => entity.Email).IsUnique();

        modelBuilder
            .Entity<NoteBlockEntityBase>()
            .HasDiscriminator<string>("block_type")
            .HasValue<TextBlockEntity>(nameof(TextBlockEntity).Replace("Entity", string.Empty))
            .HasValue<ImageBlockEntity>(nameof(ImageBlockEntity).Replace("Entity", string.Empty));

        base.OnModelCreating(modelBuilder);
    }
}
