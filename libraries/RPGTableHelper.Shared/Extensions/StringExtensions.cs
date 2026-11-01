using System.IdentityModel.Tokens.Jwt;
using System.Text.RegularExpressions;

namespace RPGTableHelper.Shared.Extensions
{
    public static class StringExtensions
    {
        // Bounds regex execution time (Sonar S6444); these linear patterns finish far below it.
        private static readonly TimeSpan RegexTimeout = TimeSpan.FromSeconds(1);

        public static string CustomNormalize(this string str)
        {
            return Regex
                .Replace(str.ToLower(), "[^A-Za-z0-9 -]", string.Empty, RegexOptions.None, RegexTimeout)
                .Replace(" ", string.Empty);
        }

        public static bool IsAlphaNumeric(this string input)
        {
            // Define the regular expression pattern for alphanumeric characters
            Regex regex = new("^[a-zA-Z0-9]+$", RegexOptions.None, RegexTimeout);

            // Use the Match method to check if the entire input string matches the pattern
            Match match = regex.Match(input);

            // Return true if there's a match (string is alphanumeric), false otherwise
            return match.Success;
        }

        public static Dictionary<string, string> GetTokenInfo(this string token)
        {
            if (string.IsNullOrEmpty(token))
            {
                throw new ArgumentNullException("token");
            }

            var tokenInfo = new Dictionary<string, string>();

            var handler = new JwtSecurityTokenHandler();
            var jwtSecurityToken = handler.ReadJwtToken(token);
            var claims = jwtSecurityToken.Claims.ToList();

            foreach (var claim in claims)
            {
                tokenInfo.Add(claim.Type, claim.Value);
            }

            var headers = jwtSecurityToken.Header.ToList();

            foreach (var header in headers)
            {
                tokenInfo.Add(header.Key, header.Value.ToString() ?? string.Empty);
            }

            return tokenInfo;
        }
    }
}
