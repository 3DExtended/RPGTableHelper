using Prodot.Patterns.Cqrs;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.DataLayer.Contracts.Queries.Apple;

/// <summary>
/// This query sends the authorization code to apple to verify, that the user indeed tried to sign up with apple.
/// </summary>
public class VerifyAppleOAuthTokenQuery : IQuery<AppleTokenResponse, VerifyAppleOAuthTokenQuery>
{
    /// <summary>
    /// The authorization code is provided to the client from apple.
    /// </summary>
    public string AuthorizationCode { get; set; } = default!;
}
