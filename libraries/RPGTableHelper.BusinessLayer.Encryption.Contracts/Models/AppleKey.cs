namespace RPGTableHelper.BusinessLayer.Encryption.Contracts.Models
{
    public class AppleKey
    {
        public string alg { get; set; }

        public string e { get; set; }

        public string kid { get; set; }

        public string kty { get; set; }

        public string n { get; set; }

        public string use { get; set; }
    }
}
