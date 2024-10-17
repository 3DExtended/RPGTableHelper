using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services
{
    public class RealSystemClock : ISystemClock
    {
        public DateTimeOffset Now => DateTimeOffset.UtcNow;
    }
}
