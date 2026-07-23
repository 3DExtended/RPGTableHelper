using FluentAssertions;

using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging.Abstractions;

using RPGTableHelper.WebApi.Services.ConfigRevisions;

namespace RPGTableHelper.Api.Tests.Services.ConfigRevisions;

public class ConfigFileBackupWriterTests
{
    [Theory]
    [InlineData("E2ETest")]
    [InlineData("LocalSignalRE2E")]
    public Task WriteBackupAsync_ShouldSkipWithoutTouchingFilesystem_InE2EHosts(string environmentName)
    {
        // arrange
        var hostEnvironment = new FakeHostEnvironment(environmentName);

        // act
        // If the E2E skip check were missing, this would attempt Directory.CreateDirectory("/app/database/configbackups")
        // on the test machine and throw (no docker mount / permissions), so a clean completion proves the skip fired.
        var act = () =>
            ConfigFileBackupWriter.WriteBackupAsync(
                hostEnvironment,
                NullLogger.Instance,
                "should-not-be-written.json",
                "{}",
                CancellationToken.None
            );

        // assert
        return act.Should().NotThrowAsync();
    }

    private sealed class FakeHostEnvironment : IHostEnvironment
    {
        public FakeHostEnvironment(string environmentName)
        {
            EnvironmentName = environmentName;
        }

        public string EnvironmentName { get; set; }
        public string ApplicationName { get; set; } = "RPGTableHelper.WebApi.Tests";
        public string ContentRootPath { get; set; } = AppContext.BaseDirectory;
        public IFileProvider ContentRootFileProvider { get; set; } = default!;
    }
}
