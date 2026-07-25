using System;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.AuthSessions;

namespace RPGTableHelper.DataLayer.Contracts.Queries.AuthSessions
{
    public class CreateAuthSessionQuery : IQuery<CreateAuthSessionResponse, CreateAuthSessionQuery>
    {
        public User.UserIdentifier UserId { get; set; } = default!;
        public DateTimeOffset ExpiresAt { get; set; }
    }
}
