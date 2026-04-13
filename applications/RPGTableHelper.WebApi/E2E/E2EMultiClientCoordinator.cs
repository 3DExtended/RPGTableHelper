using System.Threading;

namespace RPGTableHelper.WebApi.E2E;

/// <summary>
/// In-memory sync for parallel Flutter integration tests (multi-simulator). LocalSignalRE2E / E2ETest only.
/// </summary>
public static class E2EMultiClientCoordinator
{
    private static int _dmGameRegistered; // 0 or 1
    private static int _playersReaddedCount;
    private static int _phase1ReadyCount;

    public static void Reset()
    {
        Interlocked.Exchange(ref _dmGameRegistered, 0);
        Interlocked.Exchange(ref _playersReaddedCount, 0);
        Interlocked.Exchange(ref _phase1ReadyCount, 0);
    }

    /// <summary>
    /// Clears only phase 2 barriers so multiple runners can call it without racing the phase 1 barrier.
    /// </summary>
    public static void ResetPhase2Barriers()
    {
        Interlocked.Exchange(ref _dmGameRegistered, 0);
        Interlocked.Exchange(ref _playersReaddedCount, 0);
    }

    public static void MarkDmGameRegistered() => Interlocked.Exchange(ref _dmGameRegistered, 1);

    public static void NotifyPlayerReadded() => Interlocked.Increment(ref _playersReaddedCount);

    /// <summary>
    /// Each parallel Flutter runner calls this when phase 1 of the multi-sim test is done,
    /// so all three can safely reset coordinator state before phase 2 (reconnect).
    /// </summary>
    public static void MarkPhase1Ready() => Interlocked.Increment(ref _phase1ReadyCount);

    public static bool DmGameRegistered => Volatile.Read(ref _dmGameRegistered) != 0;

    public static int PlayersReaddedCount => Volatile.Read(ref _playersReaddedCount);

    public static int Phase1ReadyCount => Volatile.Read(ref _phase1ReadyCount);
}
