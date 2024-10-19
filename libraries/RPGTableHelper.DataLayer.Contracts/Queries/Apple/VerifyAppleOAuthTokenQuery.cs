using Prodot.Patterns.Cqrs;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Apple;

public class VerifyAppleOAuthTokenQuery : IQuery<AppleTokenResponse, VerifyAppleOAuthTokenQuery>
{
    public string AuthorizationCode { get; set; } = default!;
}
