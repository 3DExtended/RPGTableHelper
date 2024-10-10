using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials
{
    public class UserRequestPasswordResetQuery : IQuery<Unit, UserRequestPasswordResetQuery>
    {
        public string Email { get; set; } = default!;

        public string Username { get; set; } = default!;
    }
}
