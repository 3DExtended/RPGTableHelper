using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserIsDeletedQuery : IQuery<bool, UserIsDeletedQuery>
    {
        public User.UserIdentifier? UserIdentifier { get; set; }
    }
}
