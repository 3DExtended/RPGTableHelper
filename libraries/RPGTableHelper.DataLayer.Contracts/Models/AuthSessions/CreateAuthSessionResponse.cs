using System;

namespace RPGTableHelper.DataLayer.Contracts.Models.AuthSessions
{
    public class CreateAuthSessionResponse
    {
        public Guid AuthSessionId { get; set; }
        public string PlainRefreshToken { get; set; } = default!;
        public DateTimeOffset ExpiresAt { get; set; }
    }
}
