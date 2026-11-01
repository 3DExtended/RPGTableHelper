using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>Hands stored JSON documents (sheets, configurations) to clients unchanged.</summary>
    internal static class ExternalJson
    {
        /// <summary>
        /// Stored JSON as a token for the response, keeping every value as stored (date-like strings stay strings);
        /// an empty object if there is none or it is unreadable.
        /// </summary>
        public static JToken ParseStored(string? json)
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return new JObject();
            }

            try
            {
                using var reader = new JsonTextReader(new StringReader(json))
                {
                    DateParseHandling = DateParseHandling.None,
                    FloatParseHandling = FloatParseHandling.Decimal,
                };
                return JToken.ReadFrom(reader);
            }
            catch (JsonReaderException)
            {
                return new JObject();
            }
        }
    }
}
