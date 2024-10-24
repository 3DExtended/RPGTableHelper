namespace RPGTableHelper.Shared.Auth
{
    public interface IUserContext
    {
        /// <summary>
        /// Gets the current user's identity.
        /// </summary>
        UserIdentity User { get; }
    }
}
