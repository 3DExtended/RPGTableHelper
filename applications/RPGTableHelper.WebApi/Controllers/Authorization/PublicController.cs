using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Models;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;
using RPGTableHelper.WebApi.Options;
using RPGTableHelper.WebApi.Services;

namespace RPGTableHelper.WebApi.Controllers
{
    [ApiController]
    [Route("/[controller]")]
    public class PublicController : ControllerBase
    {
        public static readonly string MinimalAppVersionSupported = "1.0.0";

        public PublicController() { }

        [HttpGet("getminimalversion")]
        public Task<ActionResult<string>> GetMinimalAppVersion(CancellationToken cancellationToken)
        {
            return Task.FromResult<ActionResult<string>>(Ok(MinimalAppVersionSupported));
        }
    }
}
