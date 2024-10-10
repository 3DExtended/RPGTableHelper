using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials
{
    public class UserPasswordResetQuery : IQuery<Unit, UserPasswordResetQuery>
    {
        public string Email { get; set; } = default!;

        public string NewPassword { get; set; } = default!;

        public string ResetCode { get; set; } = default!;

        public string Username { get; set; } = default!;
    }
}
