using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class UserEntity : EntityBase<Guid>
    {
        public string? SignInProviderId { get; set; } = default!;
        public SupportedSignInProviders? SignInProvider { get; set; }
        public string Username { get; set; } = default!;
    }
}
