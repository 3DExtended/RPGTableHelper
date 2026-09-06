using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Controllers;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.Shared.Tests.Controllers.Authorization;

public class PublicControllerTests : ControllerTestBase
{
    public PublicControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task GetMinimalAppVersion_ShouldReturnSuccessAndMinimalVersion()
    {
        // Act
        var response = await Client.GetAsync("/public/getminimalversion");

        // Assert
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);

        var content = await response.Content.ReadAsStringAsync();
        content.Should().NotBeNull();
        content.Should().Be(PublicController.MinimalAppVersionSupported);
    }

    [Fact]
    public async Task GetCapabilities_ShouldReturnSuccessAndAdvertisedCapabilities()
    {
        // Act
        var response = await Client.GetAsync("/public/capabilities");

        // Assert
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);

        var content = await response.Content.ReadFromJsonAsync<BackendCapabilitiesDto>();
        content.Should().NotBeNull();
        content!.ApiVersion.Should().Be(PublicController.ApiVersion);
        content.Capabilities.Should().BeEquivalentTo(PublicController.SupportedCapabilities);

        // The character portrait upload feature must stay advertised; the
        // frontend gates the upload button on this exact identifier.
        content.Capabilities.Should().Contain("character-image-upload");
    }
}
