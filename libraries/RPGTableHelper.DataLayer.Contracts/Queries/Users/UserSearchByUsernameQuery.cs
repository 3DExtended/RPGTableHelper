using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserSearchByUsernameQuery : IQuery<IReadOnlyList<User>, UserSearchByUsernameQuery>
    {
        public int Limit { get; set; } = 50;

        public string UsernamePart { get; set; } = default!;
    }
}
