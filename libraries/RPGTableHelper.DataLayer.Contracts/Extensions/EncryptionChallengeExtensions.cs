using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;

namespace RPGTableHelper.DataLayer.Contracts.Extensions
{
    public static class EncryptionChallengeExtensions
    {
        public static string GetChallengeDictSerialized(this EncryptionChallenge challenge)
        {
            var challengeDict = new Dictionary<string, object>
            {
                ["ri"] = challenge.RndInt,
                ["pp"] = challenge.PasswordPrefix,
                ["id"] = challenge.Id.Value,
            };

            var challengeAsJson = JsonConvert.SerializeObject(challengeDict);

            return challengeAsJson;
        }
    }
}
