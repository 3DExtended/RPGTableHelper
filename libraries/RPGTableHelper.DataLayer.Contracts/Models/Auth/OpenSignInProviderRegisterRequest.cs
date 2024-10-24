using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.Auth
{
    public class OpenSignInProviderRegisterRequest
        : NodeModelBase<
            OpenSignInProviderRegisterRequest.OpenSignInProviderRegisterRequestIdentifier,
            Guid
        >
    {
        public string ExposedApiKey { get; set; } = default!;

        public string Email { get; set; } = default!;

        /// <summary>
        /// The "sub" of the tokens provided.
        /// </summary>
        public string IdentityProviderId { get; set; } = default!;
        public Option<string> SignInProviderRefreshToken { get; set; }
        public SupportedSignInProviders SignInProviderUsed { get; set; } = default!;

        public record OpenSignInProviderRegisterRequestIdentifier
            : Identifier<Guid, OpenSignInProviderRegisterRequestIdentifier> { }
    }
}
