using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    public class JwsE256ValidationQuery : IQuery<bool, JwsE256ValidationQuery>
    {
        public AppleKey Key { get; set; } = default!;

        public string[] StringParts { get; set; } = default!;
    }
}
