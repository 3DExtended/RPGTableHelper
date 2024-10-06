using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.Shared.Auth
{
    public class UserIdentity
    {
        // TODO fill me out!
        public string? IdentityProviderId { get; set; }

        public User.UserIdentifier UserIdentifier
        {
            get { return User.UserIdentifier.From(Guid.Parse(IdentityProviderId)); }
        }

        public string? Username { get; set; }
    }
}
