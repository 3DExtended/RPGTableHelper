using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Controllers;

namespace RPGTableHelper.Shared.Tests.Controllers.Authorization;

[Collection("Non-Parallel Collection")]
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
}
