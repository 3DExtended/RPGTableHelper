namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Options
{
    public class RSAOptions
    {
        public string PrivateRsaKeyAsPEM { get; set; } = default!;

        public string PublicRsaKeyAsPEM { get; set; } = default!;
    }
}
