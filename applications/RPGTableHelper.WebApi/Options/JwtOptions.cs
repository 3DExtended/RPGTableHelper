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

        public long NumberOfSecondsToExpire { get; set; } = 12000; // defaults to 200 minutes
    }
}
