using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Users
{
    public class UserExistsByUsernameQuery : IQuery<bool, UserExistsByUsernameQuery>
    {
        public string Username { get; set; } = default!;
    }
}
