using System.IdentityModel.Tokens.Jwt;
using System.Text.RegularExpressions;

namespace RPGTableHelper.Shared.Extensions
{
    public static class StringExtensions
    {
        public static string CustomNormalize(this string str)
        {
            return Regex.Replace(str.ToLower(), "[^A-Za-z0-9 -]", "").Replace(" ", "");
        }

        public static bool IsAlphaNumeric(this string input)
        {
            // Define the regular expression pattern for alphanumeric characters
            Regex regex = new("^[a-zA-Z0-9]+$");

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

            var TokenInfo = new Dictionary<string, string>();

            var handler = new JwtSecurityTokenHandler();
            var jwtSecurityToken = handler.ReadJwtToken(token ?? "");
            var claims = jwtSecurityToken.Claims.ToList();

            foreach (var claim in claims)
            {
                TokenInfo.Add(claim.Type, claim.Value);
            }
            var headers = jwtSecurityToken.Header.ToList();

            foreach (var header in headers)
            {
                TokenInfo.Add(header.Key, (header.Value.ToString() ?? ""));
            }

            return TokenInfo;
        }
    }
}
