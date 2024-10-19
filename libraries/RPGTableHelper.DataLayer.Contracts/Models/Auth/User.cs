using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class User : NodeModelBase<User.UserIdentifier, Guid>
    {
        public string Username { get; set; } = default!;
        public Option<string> SignInProviderId { get; set; }
        public Option<SupportedSignInProviders> SignInProvider { get; set; }

        public record UserIdentifier : Identifier<Guid, UserIdentifier> { }
    }
}
