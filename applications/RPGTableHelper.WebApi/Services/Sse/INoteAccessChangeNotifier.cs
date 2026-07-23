using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.WebApi.Services.Sse;

/// <summary>
/// sse-07: diffs note/block permitted-user sets and content changes on create/update/delete into
/// membership-scoped <c>noteAccessChanged</c> SSE notifies - ids + change kind only, never note bodies.
/// Not gated on table session presence (works from the app shell, like join requests / sse-05).
/// </summary>
public interface INoteAccessChangeNotifier
{
    /// <summary>
    /// Notifies every permitted user of a newly created block (<c>granted</c>), excluding the actor.
    /// Private blocks with an empty <c>PermittedUsers</c> list notify nobody.
    /// </summary>
    Task NotifyBlockCreatedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase createdBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    );

    /// <summary>
    /// Diffs <paramref name="previousBlock"/> and <paramref name="updatedBlock"/>'s permitted users: newly
    /// added users get <c>granted</c>, removed users get <c>revoked</c>, and users present in both sets get
    /// <c>updated</c> (covers plain content edits where permissions are unchanged). The actor is excluded
    /// from all three.
    /// </summary>
    Task NotifyBlockUpdatedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase previousBlock,
        NoteBlockModelBase updatedBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    );

    /// <summary>
    /// Notifies every permitted user of a deleted block (<c>revoked</c>), excluding the actor.
    /// </summary>
    Task NotifyBlockDeletedAsync(
        Campagne.CampagneIdentifier campagneId,
        NoteDocument.NoteDocumentIdentifier documentId,
        NoteBlockModelBase deletedBlock,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    );

    /// <summary>
    /// Notifies every user permitted on any block of the document (<c>updated</c>) about a document-level
    /// content change (title / group), excluding the actor. Block-level permissions are unaffected by this.
    /// </summary>
    Task NotifyDocumentUpdatedAsync(
        NoteDocument documentWithBlocks,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    );

    /// <summary>
    /// Notifies every user permitted on any block of the document (<c>revoked</c>) that the whole document
    /// was deleted, excluding the actor.
    /// </summary>
    Task NotifyDocumentDeletedAsync(
        NoteDocument documentWithBlocks,
        User.UserIdentifier actorUserId,
        CancellationToken cancellationToken
    );
}
