namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class AppleKey
    {
        public string alg { get; set; } = default!;

        public string e { get; set; } = default!;

        public string kid { get; set; } = default!;

        public string kty { get; set; } = default!;

        public string n { get; set; } = default!;

        public string use { get; set; } = default!;
    }
}
