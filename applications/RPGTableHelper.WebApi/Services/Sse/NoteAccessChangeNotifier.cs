using System.Text.Json;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.WebApi.Services.Sse;

public sealed class NoteAccessChangeNotifier : INoteAccessChangeNotifier
{
    private const string GrantedChangeKind = "granted";
    private const string RevokedChangeKind = "revoked";
    private const string UpdatedChangeKind = "updated";
    private const string NoteAccessChangedEventType = "noteAccessChanged";

    private readonly ISseEventHub _sseEventHub;

    public NoteAccessChangeNotifier(ISseEventHub sseEventHub)
    {
        _sseEventHub = sseEventHub;
    }

    public Task NotifyBlockCreatedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase createdBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    )
    {
        var recipients = ExcludeActor(createdBlock.PermittedUsers, actorUserId);

        return SendAsync(
            recipients,
            campagneId,
            documentId,
            createdBlock.Id,
            GrantedChangeKind,
            cancellationToken
        );
    }

    public Task NotifyBlockUpdatedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase previousBlock,
        NoteBlockModelBase updatedBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    )
    {
        var previousUserIds = previousBlock.PermittedUsers.Select(u => u.Value).ToHashSet();
        var currentUserIds = updatedBlock.PermittedUsers.Select(u => u.Value).ToHashSet();

        var gained = currentUserIds.Where(id => !previousUserIds.Contains(id));
        var lost = previousUserIds.Where(id => !currentUserIds.Contains(id));
        var remaining = currentUserIds.Where(previousUserIds.Contains);

        return Task.WhenAll(
            SendAsync(
                ExcludeActor(gained, actorUserId),
                campagneId,
                documentId,
                updatedBlock.Id,
                GrantedChangeKind,
                cancellationToken
            ),
            SendAsync(
                ExcludeActor(lost, actorUserId),
                campagneId,
                documentId,
                updatedBlock.Id,
                RevokedChangeKind,
                cancellationToken
            ),
            SendAsync(
                ExcludeActor(remaining, actorUserId),
                campagneId,
                documentId,
                updatedBlock.Id,
                UpdatedChangeKind,
                cancellationToken
            )
        );
    }

    public Task NotifyBlockDeletedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase deletedBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    )
    {
        var recipients = ExcludeActor(deletedBlock.PermittedUsers, actorUserId);

        return SendAsync(
            recipients,
            campagneId,
            documentId,
            deletedBlock.Id,
            RevokedChangeKind,
            cancellationToken
        );
    }

    public Task NotifyDocumentUpdatedAsync(
        NoteDocument documentWithBlocks,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    )
    {
        var recipients = ExcludeActor(AllPermittedUsers(documentWithBlocks), actorUserId);

        return SendAsync(
            recipients,
            documentWithBlocks.CreatedForCampagneId,
            documentWithBlocks.Id,
            blockId: null,
            UpdatedChangeKind,
            cancellationToken
        );
    }

    public Task NotifyDocumentDeletedAsync(
        NoteDocument documentWithBlocks,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    )
    {
        var recipients = ExcludeActor(AllPermittedUsers(documentWithBlocks), actorUserId);

        return SendAsync(
            recipients,
            documentWithBlocks.CreatedForCampagneId,
            documentWithBlocks.Id,
            blockId: null,
            RevokedChangeKind,
            cancellationToken
        );
    }

    private static IEnumerable<Guid> AllPermittedUsers(NoteDocument document) =>
        document.NoteBlocks.SelectMany(b => b.PermittedUsers).Select(u => u.Value);

    private static List<Guid> ExcludeActor(IEnumerable<User.UserIdentifier> userIds, User.UserIdentifier actorUserId) =>
        ExcludeActor(userIds.Select(u => u.Value), actorUserId);

    private static List<Guid> ExcludeActor(IEnumerable<Guid> userIds, User.UserIdentifier actorUserId) =>
        userIds.Where(id => id != actorUserId.Value).Distinct().ToList();

    private Task SendAsync(
        IReadOnlyCollection<Guid> recipients,
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase.NoteBlockModelBaseIdentifier? blockId,
        string changeKind,
        CancellationToken cancellationToken
    )
    {
        if (recipients.Count == 0)
        {
            return Task.CompletedTask;
        }

        var payload = JsonSerializer.Serialize(
            new
            {
                campagneId = campagneId.Value.ToString(),
                documentId = documentId.Value.ToString(),
                blockId = blockId?.Value.ToString(),
                changeKind,
            }
        );

        return _sseEventHub.SendToUsersAsync(recipients, NoteAccessChangedEventType, payload, cancellationToken);
    }
}
