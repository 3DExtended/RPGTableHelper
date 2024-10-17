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
    }
}
