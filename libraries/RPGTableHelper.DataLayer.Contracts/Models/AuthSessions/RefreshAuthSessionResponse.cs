using System;

namespace RPGTableHelper.DataLayer.Contracts.Models.AuthSessions
{
    public class RefreshAuthSessionResponse
    {
        public Guid UserId { get; set; }
        public string PlainRefreshToken { get; set; } = default!;
        public DateTimeOffset ExpiresAt { get; set; }
    }
}
