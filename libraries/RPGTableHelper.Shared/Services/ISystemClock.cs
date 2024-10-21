namespace RPGTableHelper.Shared.Services
{
    public interface ISystemClock
    {
        DateTimeOffset Now { get; }
    }
}
