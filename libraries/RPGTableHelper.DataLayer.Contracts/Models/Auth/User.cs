using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class User : NodeModelBase<User.UserIdentifier>, IIpAddressBasedNode
    {
        public string Username { get; set; } = default!;

        public record UserIdentifier : Identifier<Guid, UserIdentifier> { }
    }
}
