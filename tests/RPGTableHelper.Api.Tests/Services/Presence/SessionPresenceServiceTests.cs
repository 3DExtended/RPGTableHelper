using FluentAssertions;

using NSubstitute;

using RPGTableHelper.WebApi.Services.Presence;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Services.Presence;

public class SessionPresenceServiceTests
{
    [Fact]
    public async Task EnterAsync_BroadcastsParticipantOnline_ToOtherAlreadyEnteredParticipant()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub);

        var campagneId = Guid.NewGuid();
        var existingParticipantId = Guid.NewGuid();
        var enteringUserId = Guid.NewGuid();

        await sut.EnterAsync(campagneId, existingParticipantId, CancellationToken.None);
        sseEventHub.ClearReceivedCalls();

        // act
        await sut.EnterAsync(campagneId, enteringUserId, CancellationToken.None);

        // assert
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == existingParticipantId),
                "participantOnline",
                Arg.Is<string>(json => json.Contains(enteringUserId.ToString()) && json.Contains(campagneId.ToString())),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task LeaveAsync_BroadcastsParticipantOffline_ToRemainingParticipant()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub);

        var campagneId = Guid.NewGuid();
        var remainingParticipantId = Guid.NewGuid();
        var leavingUserId = Guid.NewGuid();

        await sut.EnterAsync(campagneId, remainingParticipantId, CancellationToken.None);
        await sut.EnterAsync(campagneId, leavingUserId, CancellationToken.None);
        sseEventHub.ClearReceivedCalls();

        // act
        await sut.LeaveAsync(campagneId, leavingUserId, CancellationToken.None);

        // assert
        sut.IsOnline(campagneId, leavingUserId).Should().BeFalse();
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == remainingParticipantId),
                "participantOffline",
                Arg.Is<string>(json => json.Contains(leavingUserId.ToString()) && json.Contains(campagneId.ToString())),
                Arg.Any<CancellationToken>()
            );
    }

    [Fact]
    public async Task GetOnlineParticipants_ReturnsCurrentlyOnlineUserIds_ForThatCampagneOnly()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub);

        var campagneId = Guid.NewGuid();
        var otherCampagneId = Guid.NewGuid();
        var participantOneId = Guid.NewGuid();
        var participantTwoId = Guid.NewGuid();
        var otherCampagneParticipantId = Guid.NewGuid();

        await sut.EnterAsync(campagneId, participantOneId, CancellationToken.None);
        await sut.EnterAsync(campagneId, participantTwoId, CancellationToken.None);
        await sut.EnterAsync(otherCampagneId, otherCampagneParticipantId, CancellationToken.None);

        // act
        var onlineParticipants = sut.GetOnlineParticipants(campagneId);

        // assert
        onlineParticipants.Should().BeEquivalentTo(new[] { participantOneId, participantTwoId });
    }

    [Fact]
    public void GetOnlineParticipants_ForCampagneWithNoParticipants_ReturnsEmpty()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub);

        // act
        var onlineParticipants = sut.GetOnlineParticipants(Guid.NewGuid());

        // assert
        onlineParticipants.Should().BeEmpty();
    }

    [Fact]
    public async Task OnSseDisconnectedAsync_ThenReconnectWithinGrace_DoesNotGoOfflineOrBroadcast()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub, gracePeriod: TimeSpan.FromMilliseconds(150));

        var campagneId = Guid.NewGuid();
        var otherParticipantId = Guid.NewGuid();
        var flakeyUserId = Guid.NewGuid();

        await sut.EnterAsync(campagneId, otherParticipantId, CancellationToken.None);
        await sut.EnterAsync(campagneId, flakeyUserId, CancellationToken.None);
        sseEventHub.ClearReceivedCalls();

        // act: brief SSE drop, reconnect well within the grace period
        await sut.OnSseDisconnectedAsync(flakeyUserId, CancellationToken.None);
        await Task.Delay(30);
        await sut.OnSseConnectedAsync(flakeyUserId, CancellationToken.None);

        // wait past the original grace deadline to prove no delayed offline transition fires
        await Task.Delay(250);

        // assert
        sut.IsOnline(campagneId, flakeyUserId).Should().BeTrue();
        await sseEventHub
            .DidNotReceive()
            .SendToUsersAsync(Arg.Any<IEnumerable<Guid>>(), "participantOffline", Arg.Any<string>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task OnSseDisconnectedAsync_WithoutReconnectAfterGrace_GoesOfflineAndBroadcasts()
    {
        // arrange
        var sseEventHub = Substitute.For<ISseEventHub>();
        var sut = new SessionPresenceService(sseEventHub, gracePeriod: TimeSpan.FromMilliseconds(50));

        var campagneId = Guid.NewGuid();
        var otherParticipantId = Guid.NewGuid();
        var droppedUserId = Guid.NewGuid();

        await sut.EnterAsync(campagneId, otherParticipantId, CancellationToken.None);
        await sut.EnterAsync(campagneId, droppedUserId, CancellationToken.None);
        sseEventHub.ClearReceivedCalls();

        // act
        await sut.OnSseDisconnectedAsync(droppedUserId, CancellationToken.None);

        // Poll instead of a fixed sleep — under parallel suite load a short Delay can
        // race the fire-and-forget grace timer before it has marked the user offline.
        var wentOffline = await WaitUntilAsync(
            () => !sut.IsOnline(campagneId, droppedUserId),
            timeout: TimeSpan.FromSeconds(2)
        );

        // assert
        wentOffline.Should().BeTrue("grace timer should mark the user offline");
        await sseEventHub
            .Received(1)
            .SendToUsersAsync(
                Arg.Is<IEnumerable<Guid>>(ids => ids.Single() == otherParticipantId),
                "participantOffline",
                Arg.Is<string>(json => json.Contains(droppedUserId.ToString()) && json.Contains(campagneId.ToString())),
                Arg.Any<CancellationToken>()
            );
    }

    private static async Task<bool> WaitUntilAsync(Func<bool> condition, TimeSpan timeout)
    {
        var deadline = DateTime.UtcNow + timeout;
        while (DateTime.UtcNow < deadline)
        {
            if (condition())
            {
                return true;
            }

            await Task.Delay(10);
        }

        return condition();
    }
}
