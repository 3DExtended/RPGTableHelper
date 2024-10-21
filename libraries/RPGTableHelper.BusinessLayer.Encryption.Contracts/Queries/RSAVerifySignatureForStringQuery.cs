using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    public class RSAVerifySignatureForStringQuery : IQuery<bool, RSAVerifySignatureForStringQuery>
    {
        public string OriginalMessage { get; set; } = default!;

        public Option<string> PublicKeyOverride { get; set; } = Option.None;

        public string Signature { get; set; } = default!;
    }
}
