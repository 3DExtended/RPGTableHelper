using FluentAssertions;

using RPGTableHelper.Shared.Auth;
using RPGTableHelper.WebApi.Services.Sse;

namespace RPGTableHelper.Api.Tests.Services.Sse;

public class ExternalEventCatalogTests
{
    [Theory]
    [InlineData("initiativeRequested", ApiKeyScopes.FightsPlay)]
    [InlineData("initiativeSettled", ApiKeyScopes.FightsPlay)]
    [InlineData("fightEnded", ApiKeyScopes.FightsPlay)]
    [InlineData("characterConfigChanged", ApiKeyScopes.CharactersRead)]
    [InlineData("itemsGranted", ApiKeyScopes.CharactersRead)]
    [InlineData("campagneConfigChanged", ApiKeyScopes.CampaignsRead)]
    [InlineData("noteAccessChanged", ApiKeyScopes.NotesRead)]
    [InlineData("participantOnline", ApiKeyScopes.Events)]
    [InlineData("participantOffline", ApiKeyScopes.Events)]
    public void AnEvent_ReachesAKeyOnlyWithItsScope(string eventType, string scope)
    {
        ExternalEventCatalog.IsDelivered(eventType, new[] { scope }).Should().BeTrue();
        ExternalEventCatalog.IsDelivered(eventType, ApiKeyScopes.All.Where(s => s != scope).ToList()).Should().BeFalse();
    }

    [Theory]
    [InlineData("fightUpdated")]
    [InlineData("playersAreAskedForRolls")]
    [InlineData("dmReceivedFightSequenceAnswer")]
    [InlineData("joinRequestCreated")]
    [InlineData("joinRequestResolved")]
    [InlineData("someEventAddedLater")]
    public void AnEventThatIsNotForPlayers_NeverReachesAKey(string eventType)
    {
        ExternalEventCatalog.IsDelivered(eventType, ApiKeyScopes.All).Should().BeFalse();
    }
}
