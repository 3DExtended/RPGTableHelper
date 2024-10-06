using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries
{
    /// <summary>
    /// Returns base64 encoded UTF-8 String
    /// </summary>
    public class RSAEncryptStringQuery : IQuery<string, RSAEncryptStringQuery>
    {
        public Option<string> PublicKeyOverride { get; set; } = Option.None;

        // has to be UTF-8
        public string StringToEncrypt { get; set; } = default(string)!;
    }
}
