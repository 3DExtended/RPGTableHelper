using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities
{
    public class OpenSignInProviderRegisterRequestEntity : EntityBase<Guid>
    {
        public string ExposedApiKey { get; set; } = default!;
        public string Email { get; set; } = default!;

        /// <summary>
        /// The "sub" of the tokens provided.
        /// </summary>
        public string IdentityProviderId { get; set; } = default!;
        public string? SignInProviderRefreshToken { get; set; } = null;
        public SupportedSignInProviders SignInProviderUsed { get; set; } = default!;
    }
}
