using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    public class RSASignStringQuery : IQuery<string, RSASignStringQuery>
    {
        public string MessageToSign { get; set; } = default!;

        public Option<string> PrivateKeyOverride { get; set; } = Option.None;
    }
}
