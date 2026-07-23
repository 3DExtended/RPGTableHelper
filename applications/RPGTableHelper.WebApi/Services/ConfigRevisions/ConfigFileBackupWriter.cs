using System.Diagnostics;

using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace RPGTableHelper.WebApi.Services.ConfigRevisions;

/// <summary>
/// Writes timestamped filesystem backups of config documents under <c>configbackups/</c> on every successful
/// persist, mirroring the existing SignalR hub backup behavior. Skipped in E2E test hosts to keep tests deterministic.
/// </summary>
public static class ConfigFileBackupWriter
{
    public static async Task WriteBackupAsync(
        IHostEnvironment hostEnvironment,
        ILogger logger,
        string fileName,
        string content,
        CancellationToken cancellationToken
    )
    {
        if (hostEnvironment.IsEnvironment("E2ETest") || hostEnvironment.IsEnvironment("LocalSignalRE2E"))
        {
            return;
        }

        var currentDirectory = "/app/database/"; // mounting point from docker compose

        if (Debugger.IsAttached)
        {
            currentDirectory = "./";
        }

        var fileBackupFolders = "configbackups";
        Directory.CreateDirectory(Path.Combine(currentDirectory, fileBackupFolders));

        var filePath = Path.Combine(currentDirectory, fileBackupFolders, fileName);
        try
        {
            await File.WriteAllTextAsync(filePath, content, cancellationToken).ConfigureAwait(false);
            logger.LogInformation($"File saved to {filePath}");
        }
        catch (Exception ex)
        {
            logger.LogInformation($"An error occurred: {ex.Message}");
        }
    }
}
