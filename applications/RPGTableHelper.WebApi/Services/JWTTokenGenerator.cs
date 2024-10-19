using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services
{
    public class JWTTokenGenerator : IJWTTokenGenerator
    {
        public readonly IConfiguration _configuration;
        public readonly ISystemClock _systemClock;

        public JWTTokenGenerator(ISystemClock systemClock, IConfiguration configuration)
        {
            _systemClock = systemClock;
            _configuration = configuration;
        }

        public string GetJWTToken(string username, string userIdentityProviderId)
        {
            var issuer = _configuration["Jwt:Issuer"] ?? "api";
            var audience = _configuration["Jwt:Audience"] ?? "api";
            var key = Encoding.ASCII.GetBytes(
                _configuration["Jwt:Key"] ?? string.Join("", Enumerable.Repeat("asdfasdf", 200))
            );

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(
                    new[]
                    {
                        new Claim("Id", Guid.NewGuid().ToString()),
                        new Claim("identityproviderid", userIdentityProviderId), // TODO replace me with the identityproviderid
                        new Claim(JwtRegisteredClaimNames.Name, username),
                        new Claim(JwtRegisteredClaimNames.Sub, username),
                        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                    }
                ),
                Expires = _systemClock.Now.DateTime.AddMinutes(200),
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
