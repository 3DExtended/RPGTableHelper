using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Queries;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Apple;
using RPGTableHelper.Shared.Extensions;
using RPGTableHelper.Shared.Options;

namespace RPGTableHelper.BusinessLayer.QueryHandlers;

public class AppleVerifyTokenAndReceiveUserDetailsQueryHandler
    : IQueryHandler<
        AppleVerifyTokenAndReceiveUserDetailsQuery,
        (string? internalId, string? email, string? appleRefreshToken)
    >
{
    private readonly IQueryProcessor _queryProcessor;
    private readonly AppleAuthOptions _appleOptions;

    public AppleVerifyTokenAndReceiveUserDetailsQueryHandler(
        IQueryProcessor queryProcessor,
        AppleAuthOptions appleOptions
    )
    {
        _queryProcessor = queryProcessor;
        _appleOptions = appleOptions;
    }

    public IQueryHandler<
        AppleVerifyTokenAndReceiveUserDetailsQuery,
        (string? internalId, string? email, string? appleRefreshToken)
    > Successor { get; set; } = default!;

    public async Task<
        Option<(string? internalId, string? email, string? appleRefreshToken)>
    > RunQueryAsync(
        AppleVerifyTokenAndReceiveUserDetailsQuery query,
        CancellationToken cancellationToken
    )
    {
        var appleKeys = await new AppleAuthKeysQuery()
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (appleKeys.IsNone)
        {
            return Option.None;
        }

        // decode identitytoken
        var tokenDetails = query.LoginDetails.IdentityToken.GetTokenInfo();
        var appleKeyForIdentityToken = appleKeys
            .Get()
            .Keys.Single(k => k.kid == tokenDetails["kid"]);

        // vertify token with public key:
        string[] parts = query.LoginDetails.IdentityToken.Split('.');
        string header = parts[0];
        string payload = parts[1];
        await ValidateJwsE256(appleKeyForIdentityToken, parts, cancellationToken);

        // TODO nonce is something I pass in through flutter. I have to make sure, a given nonce is only used ONCE...
        // var nonce = tokenDetails["nonce"];

        // Verify that the iss field contains https://appleid.apple.com
        if (tokenDetails["iss"] != "https://appleid.apple.com")
        {
            return Option.None;
        }

        // Verify that the aud field is the developer’s client_id
        if (tokenDetails["aud"] != _appleOptions.ClientId)
        {
            return Option.None;
        }

        // Verify that the time is earlier than the exp value of the token
        var expDateOfToken = DateTime.UnixEpoch.AddSeconds(+long.Parse(tokenDetails["exp"]));

        if (DateTime.UtcNow > expDateOfToken)
        {
            return Option.None;
        }

        var appleTokenResponse = await new VerifyAppleOAuthTokenQuery
        {
            AuthorizationCode = query.LoginDetails.AuthorizationCode,
        }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (appleTokenResponse.IsNone)
            return Option.None;

        // decode id token
        var appleAuthTokenDetails = appleTokenResponse.Get().id_token!.GetTokenInfo();

        // some string uniquely identifying the user
        var internalId = appleAuthTokenDetails["sub"];
        var email = appleAuthTokenDetails["email"]!;
        var appleRefreshToken = appleTokenResponse.Get().refresh_token ?? null;

        return (internalId, email, appleRefreshToken);
    }

    private async Task ValidateJwsE256(
        AppleKey appleKeyForIdentityToken,
        string[] parts,
        CancellationToken cancellationToken
    )
    {
        var validationResult = await new JwsE256ValidationQuery
        {
            Key = appleKeyForIdentityToken,
            StringParts = parts,
        }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (validationResult.IsNone || validationResult.Get() == false)
        {
            throw new ApplicationException(string.Format("Invalid signature"));
        }
    }
}
