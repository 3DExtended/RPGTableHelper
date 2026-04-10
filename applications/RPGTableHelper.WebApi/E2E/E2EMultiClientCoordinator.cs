using System.Threading;

namespace RPGTableHelper.WebApi.E2E;

/// <summary>
/// In-memory sync for parallel Flutter integration tests (multi-simulator). LocalSignalRE2E / E2ETest only.
/// </summary>
public static class E2EMultiClientCoordinator
{
    private static int _dmGameRegistered; // 0 or 1
    private static int _playersReaddedCount;

    public static void Reset()
    {
        Interlocked.Exchange(ref _dmGameRegistered, 0);
        Interlocked.Exchange(ref _playersReaddedCount, 0);
    }

    public static void MarkDmGameRegistered() => Interlocked.Exchange(ref _dmGameRegistered, 1);

    public static void NotifyPlayerReadded() => Interlocked.Increment(ref _playersReaddedCount);

    public static bool DmGameRegistered => Volatile.Read(ref _dmGameRegistered) != 0;

    public static int PlayersReaddedCount => Volatile.Read(ref _playersReaddedCount);
}
