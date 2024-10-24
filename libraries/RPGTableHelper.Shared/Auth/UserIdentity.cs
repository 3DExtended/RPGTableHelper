using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.Shared.Auth
{
    public class UserIdentity
    {
        public string? IdentityProviderId { get; set; }

        public User.UserIdentifier UserIdentifier
        {
            get
            {
                return User.UserIdentifier.From(
                    IdentityProviderId == null ? Guid.Empty : Guid.Parse(IdentityProviderId!)
                );
            }
        }

        public string? Username { get; set; }
    }
}
