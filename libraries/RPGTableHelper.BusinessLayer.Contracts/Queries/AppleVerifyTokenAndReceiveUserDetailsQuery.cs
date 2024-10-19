using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;

namespace RPGTableHelper.BusinessLayer.Contracts.Queries
{
    public class AppleVerifyTokenAndReceiveUserDetailsQuery
        : IQuery<
            (string? internalId, string? email, string? appleRefreshToken),
            AppleVerifyTokenAndReceiveUserDetailsQuery
        >
    {
        public AppleLoginDetails LoginDetails { get; set; } = default!;
    }
}
