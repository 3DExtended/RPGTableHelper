using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;

namespace RPGTableHelper.BusinessLayer.Contracts.Queries
{
    /// <summary>
    /// This query verifies the users details, the token and extracts the required information from this token.
    /// </summary>
    public class AppleVerifyTokenAndReceiveUserDetailsQuery
        : IQuery<
            (string? internalId, string? email, string? appleRefreshToken),
            AppleVerifyTokenAndReceiveUserDetailsQuery
        >
    {
        /// <summary>
        /// The information of the user trying to login or sign up with apple.
        /// </summary>
        public AppleLoginDetails LoginDetails { get; set; } = default!;
    }
}
