using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Options;

namespace RPGTableHelper.WebApi.Services
{
    public class JWTTokenGenerator : IJWTTokenGenerator
    {
        private readonly JwtOptions _jwtOptions;
        private readonly ISystemClock _systemClock;

        public JWTTokenGenerator(ISystemClock systemClock, JwtOptions jwtOptions)
        {
            _systemClock = systemClock;
            _jwtOptions = jwtOptions;
        }

        public string GetJWTToken(string username, string userIdentityProviderId)
        {
            var issuer = _jwtOptions.Issuer ?? "api";
            var audience = _jwtOptions.Audience ?? "api";
            var key = Encoding.ASCII.GetBytes(
                _jwtOptions.Key ?? string.Join(string.Empty, Enumerable.Repeat("asdfasdf", 200))
            );

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(
                    new[]
                    {
                        new Claim("Id", Guid.NewGuid().ToString()),
                        new Claim("identityproviderid", userIdentityProviderId),
                        new Claim(JwtRegisteredClaimNames.Name, username),
                        new Claim(JwtRegisteredClaimNames.Sub, username),
                        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                    }
                ),
                Expires = _systemClock.Now.DateTime.AddSeconds(_jwtOptions.NumberOfSecondsToExpire),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha512Signature
                ),
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            var jwtToken = tokenHandler.WriteToken(token);
            return jwtToken;
        }
    }
}
