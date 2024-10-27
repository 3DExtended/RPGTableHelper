using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.SignalR.Client;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.Shared.Tests.Controllers.Authorization;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.SignalRControllers;

public class PublicControllerTests : ControllerTestBase
{
    public PublicControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task Echo_ShouldReturnSentString()
    {
        // arrange
        Dictionary<string, object>? challengeDict = await RegisterControllerTests.GenerateAndReceiveEncryptionChallenge(
            QueryProcessor,
            Client,
            Context!
        );

        string? jwtResult = await RegisterControllerTests.LoginAndReceiveJWT(QueryProcessor, Client, challengeDict);

        await RegisterControllerTests.VerifyLoginValidity(Client, jwtResult);

        var handle = Factory.Server.CreateHandler();
        var connection = new HubConnectionBuilder()
            .WithUrl(
                "wss://localhost" + "/Chat",
                options =>
                {
                    options.HttpMessageHandlerFactory = _ => handle;
                    options.AccessTokenProvider = () => Task.FromResult(jwtResult);
                }
            )
            .Build();

        string? resultFromServer = null;
        connection.On<string>(
            "Echo",
            (message) =>
            {
                resultFromServer = message;
            }
        );
        await connection.StartAsync();
        var message = "Ich komme aus dem Test";

        // act
        await connection.InvokeAsync(nameof(RpgServerSignalRHub.Echo), message, CancellationToken.None);

        // wait so that server can invoke "Echo" on this connection
        await Task.Delay(1000);

        // assert
        resultFromServer.Should().NotBeNullOrEmpty();
        resultFromServer.Should().Be(message);
    }

    [Fact]
    public async Task Echo_ShouldFailIfUnauthorized()
    {
        // arrange
        var handle = Factory.Server.CreateHandler();
        var connection = new HubConnectionBuilder()
            .WithUrl(
                "wss://localhost" + "/Chat",
                options =>
                {
                    options.HttpMessageHandlerFactory = _ => handle;
                    options.AccessTokenProvider = () => Task.FromResult((string?)"asdfasdf"); // some invalid JWT
                }
            )
            .Build();

        string? resultFromServer = null;
        connection.On<string>(
            "Echo",
            (message) =>
            {
                resultFromServer = message;
            }
        );

        var task1 = () => connection.StartAsync();

        await task1.Should().ThrowAsync<HttpRequestException>();

        var message = "Ich komme aus dem Test";

        await Task.Delay(1000);

        // act
        var task = () => connection.InvokeAsync(nameof(RpgServerSignalRHub.Echo), message, CancellationToken.None);

        // assert
        await task.Should().ThrowAsync<InvalidOperationException>();

        resultFromServer.Should().BeNull();
    }
}
