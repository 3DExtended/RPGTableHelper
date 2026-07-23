using FluentAssertions;

using NSubstitute;

using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Services.Sse;

/// <summary>
/// Coverage for sse-07: diffing block/document permitted-user sets and content changes into
/// membership-scoped <c>noteAccessChanged</c> SSE notifies (ids + change kind only, no note bodies).
/// </summary>
public class NoteAccessChangeNotifierTests
{
    [Fact]
    public async Task NotifyBlockCreatedAsync_SendsGranted_ToPermittedUsers_ExcludingActor()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var documentId = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var sharedWithUserId = User.UserIdentifier.From(Guid.NewGuid());

        var createdBlock = new TextBlock
        {
            Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "hello",
            PermittedUsers = new List<User.UserIdentifier> { actorUserId, sharedWithUserId },
        };

        // act
        await sut.NotifyBlockCreatedAsync(campagneId, documentId, createdBlock, actorUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == sharedWithUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json =>
                    json.Contains(documentId.Value.ToString())
                    && json.Contains(createdBlock.Id.Value.ToString())
                    && json.Contains(campagneId.Value.ToString())
                    && json.Contains("granted")
                ),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyBlockCreatedAsync_WithEmptyPermittedUsers_NotifiesNobody()
    {
        // arrange: private new block - nobody shared with yet.
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var documentId = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());

        var createdBlock = new TextBlock
        {
            Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "private",
            PermittedUsers = new List<User.UserIdentifier>(),
        };

        // act
        await sut.NotifyBlockCreatedAsync(campagneId, documentId, createdBlock, actorUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .DidNotReceive()
            .SendToUsersAsync(
                Arg.Any<IEnumerable<Guid>>(),
                Arg.Any<string>(),
                Arg.Any<string>(),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyBlockUpdatedAsync_NotifiesGainedUsersAsGranted_AndLostUsersAsRevoked()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var documentId = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
        var blockId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var gainedUserId = User.UserIdentifier.From(Guid.NewGuid());
        var lostUserId = User.UserIdentifier.From(Guid.NewGuid());

        var previousBlock = new TextBlock
        {
            Id = blockId,
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "old",
            PermittedUsers = new List<User.UserIdentifier> { lostUserId },
        };

        var updatedBlock = new TextBlock
        {
            Id = blockId,
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "new",
            PermittedUsers = new List<User.UserIdentifier> { gainedUserId },
        };

        // act
        await sut.NotifyBlockUpdatedAsync(
            campagneId,
            documentId,
            previousBlock,
            updatedBlock,
            actorUserId,
            CancellationToken.None
        );

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == gainedUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("granted")),
                Arg.Any<CancellationToken>()
            );

        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == lostUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("revoked")),
                Arg.Any<CancellationToken>()
            );

        await sseEventHub
            .DidNotReceive()
            .SendToUsersAsync(
                Arg.Any<IEnumerable<Guid>>(),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("updated")),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyBlockUpdatedAsync_NotifiesRemainingShareeAsUpdated_OnContentOnlyChange()
    {
        // arrange: permitted users unchanged, only the content changed.
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var documentId = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
        var blockId = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var shareeUserId = User.UserIdentifier.From(Guid.NewGuid());

        var previousBlock = new TextBlock
        {
            Id = blockId,
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "old",
            PermittedUsers = new List<User.UserIdentifier> { shareeUserId },
        };

        var updatedBlock = new TextBlock
        {
            Id = blockId,
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "new",
            PermittedUsers = new List<User.UserIdentifier> { shareeUserId },
        };

        // act
        await sut.NotifyBlockUpdatedAsync(
            campagneId,
            documentId,
            previousBlock,
            updatedBlock,
            actorUserId,
            CancellationToken.None
        );

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == shareeUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("updated")),
                Arg.Any<CancellationToken>()
            );

        await sseEventHub
            .DidNotReceive()
            .SendToUsersAsync(
                Arg.Any<IEnumerable<Guid>>(),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("granted") || json.Contains("revoked")),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyBlockDeletedAsync_SendsRevoked_ToPermittedUsers_ExcludingActor()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var documentId = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var shareeUserId = User.UserIdentifier.From(Guid.NewGuid());

        var deletedBlock = new TextBlock
        {
            Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
            NoteDocumentId = documentId,
            CreatingUserId = actorUserId,
            MarkdownText = "gone",
            PermittedUsers = new List<User.UserIdentifier> { actorUserId, shareeUserId },
        };

        // act
        await sut.NotifyBlockDeletedAsync(campagneId, documentId, deletedBlock, actorUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == shareeUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("revoked") && json.Contains(deletedBlock.Id.Value.ToString())),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyDocumentUpdatedAsync_SendsUpdated_ToAllSharees_AcrossBlocks_ExcludingActor()
    {
        // arrange: document metadata (e.g. title) changed - block permissions untouched.
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var shareeOneId = User.UserIdentifier.From(Guid.NewGuid());
        var shareeTwoId = User.UserIdentifier.From(Guid.NewGuid());

        var document = new NoteDocument
        {
            Id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid()),
            CreatedForCampagneId = campagneId,
            CreatingUserId = actorUserId,
            Title = "Updated title",
            GroupName = "Group",
            NoteBlocks = new List<NoteBlockModelBase>
            {
                new TextBlock
                {
                    Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
                    CreatingUserId = actorUserId,
                    MarkdownText = "a",
                    PermittedUsers = new List<User.UserIdentifier> { shareeOneId },
                },
                new TextBlock
                {
                    Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
                    CreatingUserId = actorUserId,
                    MarkdownText = "b",
                    PermittedUsers = new List<User.UserIdentifier> { shareeTwoId, actorUserId },
                },
            },
        };

        // act
        await sut.NotifyDocumentUpdatedAsync(document, actorUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids =>
                    ids.Count() == 2 && ids.Contains(shareeOneId.Value) && ids.Contains(shareeTwoId.Value)
                ),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("updated") && !json.Contains(actorUserId.Value.ToString())),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task NotifyDocumentDeletedAsync_SendsRevoked_ToAllSharees_AcrossBlocks_ExcludingActor()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new NoteAccessChangeNotifier(sseEventHub);

        var campagneId = Campagne.CampagneIdentifier.From(Guid.NewGuid());
        var actorUserId = User.UserIdentifier.From(Guid.NewGuid());
        var shareeUserId = User.UserIdentifier.From(Guid.NewGuid());

        var document = new NoteDocument
        {
            Id = NoteDocument.NoteDocumentIdentifier.From(Guid.NewGuid()),
            CreatedForCampagneId = campagneId,
            CreatingUserId = actorUserId,
            Title = "Doomed",
            GroupName = "Group",
            NoteBlocks = new List<NoteBlockModelBase>
            {
                new TextBlock
                {
                    Id = NoteBlockModelBase.NoteBlockModelBaseIdentifier.From(Guid.NewGuid()),
                    CreatingUserId = actorUserId,
                    MarkdownText = "a",
                    PermittedUsers = new List<User.UserIdentifier> { shareeUserId },
                },
            },
        };

        // act
        await sut.NotifyDocumentDeletedAsync(document, actorUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == shareeUserId.Value),
                "noteAccessChanged",
                Arg.Is<string>(json => json.Contains("revoked") && json.Contains(document.Id.Value.ToString())),
                Arg.Any<CancellationToken>()
            );
    }
}
