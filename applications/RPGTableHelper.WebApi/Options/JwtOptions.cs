using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RPGTableHelper.WebApi.Options
{
    public class JwtOptions
    {
        public string Issuer { get; set; } = default!;
        public string Audience { get; set; } = default!;
        public string Key { get; set; } = default!;

        public long NumberOfSecondsToExpire { get; set; } = 21600; // defaults to 6 hours

        public long RefreshTokenNumberOfSecondsToExpire { get; set; } = 7776000; // defaults to 90 days
    }
}
