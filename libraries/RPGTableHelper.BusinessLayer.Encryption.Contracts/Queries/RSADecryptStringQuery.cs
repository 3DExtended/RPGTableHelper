using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    public class RSADecryptStringQuery : IQuery<string, RSADecryptStringQuery>
    {
        public Option<string> PrivateKeyOverride { get; set; } = Option.None;

        public string StringToDecrypt { get; set; }
    }
}
