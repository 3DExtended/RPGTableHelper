using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserExistsByInternalIdQuery
        : IQuery<User.UserIdentifier, UserExistsByInternalIdQuery>
    {
        public string InternalId { get; set; } = default!;
    }
}
