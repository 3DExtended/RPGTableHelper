using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using NSubstitute.Core;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Controllers;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.Shared.Tests.Controllers.Authorization;

public class RegisterControllerTests : ControllerTestBase
{
    public RegisterControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task RegisterUsingUsername_ShouldBeSuccessful()
    {
        // get encryption challenge
        Dictionary<string, object>? challengeDict = await GenerateAndReceiveEncryptionChallenge(
            QueryProcessor,
            Client,
            Context!
        );

        // execute register as new user
        string? jwtResult = await LoginAndReceiveJWT(QueryProcessor, Client, challengeDict);

        // verify jwt is valid for login
        await VerifyLoginValidity(Client, jwtResult);
    }

    [Fact]
    public async Task VerifyEmailAsync_ShouldBeSuccessful()
    {
        // arrange
        var userEntity = new UserEntity { Id = Guid.Empty, Username = "TestUser" };
        using (var context = await ContextFactory!.CreateDbContextAsync(default))
        {
            await context.Users.AddAsync(userEntity, default!);
            await context.SaveChangesAsync(default);
        }

        var requestEntity = new UserCredentialEntity
        {
            Id = Guid.Empty,
            Email = "asdf@asdf.de",
            EmailVerified = false,
            Deleted = false,
            UserId = userEntity.Id,
        };

        using (var context = await ContextFactory!.CreateDbContextAsync(default))
        {
            await context.UserCredentials.AddAsync(requestEntity, default!);
            await context.SaveChangesAsync(default);
        }

        var useridbase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(userEntity.Id.ToString()));
        var useridsignature = await new RSASignStringQuery { MessageToSign = userEntity.Id.ToString() }.RunAsync(
            QueryProcessor,
            default
        );

        // act
        var response = await Client.GetAsync(
            $"/register/verifyemail/{useridbase64.Replace('/', '_')}/{useridsignature.Get().Replace('/', '_')}"
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        using (var context = await ContextFactory!.CreateDbContextAsync(default))
        {
            var entities = await context.UserCredentials.ToListAsync(default);
            entities.Count.Should().Be(1);
            entities[0].EmailVerified.Should().BeTrue();
        }
    }

    [Fact]
    public async Task RegisterWithApiKeyAsync_ShouldBeSuccessful()
    {
        // arrange
        var requestEntity = new OpenSignInProviderRegisterRequestEntity
        {
            Id = Guid.Empty,
            Email = "asdf@asdf.de",
            ExposedApiKey = "sdfghjklölkjhgfdfghjk",
            IdentityProviderId = "64f1f32a-d40b-4809-b716-b982441cc2ef",
            SignInProviderRefreshToken = "70919681-a118-49c3-833f-9f02e848182a",
            SignInProviderUsed = SupportedSignInProviders.Apple,
        };

        using (var context = await ContextFactory!.CreateDbContextAsync(default))
        {
            await context.OpenSignInProviderRegisterRequests.AddAsync(requestEntity, default!);
            await context.SaveChangesAsync(default);
        }

        var requestBody = new RegisterWithApiKeyDto { ApiKey = requestEntity.ExposedApiKey, Username = "TestUsername" };

        // act
        var response = await Client.PostAsJsonAsync("/register/registerwithapikey", requestBody);

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var jwtResult = await response.Content.ReadAsStringAsync();
        jwtResult.Should().NotBeNullOrEmpty();
        await VerifyLoginValidity(Client, jwtResult);
    }

    internal static async Task VerifyLoginValidity(HttpClient client, string? jwtResult)
    {
        // arrange
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", jwtResult);

        // act
        var response = await client.GetAsync("/SignIn/testlogin");

        // assert
        if (!response.IsSuccessStatusCode)
        {
            // Log error response content
            var errorContent = await response.Content.ReadAsStringAsync();
            Console.WriteLine("Error Response Content: " + errorContent); // Helpful for debugging
        }

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var responseText = await response.Content.ReadAsStringAsync();
        responseText.Should().Be("Welcome");
    }

    internal static async Task<string?> LoginAndReceiveJWT(
        IQueryProcessor queryProcessor,
        HttpClient client,
        Dictionary<string, object>? challengeDict
    )
    {
        // arrange
        var registerDto = new RegisterWithUsernamePasswordDto
        {
            Username = "TestUser1",
            EncryptionChallengeIdentifier = EncryptionChallenge.EncryptionChallengeIdentifier.From(
                Guid.Parse(challengeDict!["id"]!.ToString()!)
            ),
            UserSecret = "mysupersecretpassword",
            Email = "asdf@asdf.de",
        };

        var serializedRegisterDto = JsonConvert.SerializeObject(registerDto);
        var encryptedRegisterDto = await new RSAEncryptStringQuery { StringToEncrypt = serializedRegisterDto }
            .RunAsync(queryProcessor, default!)
            .ConfigureAwait(true);

        // act
        var response = await client.PostAsync(
            "/register/register",
            new StringContent($"\"{encryptedRegisterDto.Get()}\"", Encoding.UTF8, "application/json")
        );

        // assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var jwtResult = await response.Content.ReadAsStringAsync();
        jwtResult.Should().NotBeNullOrEmpty();

        return jwtResult;
    }

    internal static async Task<Dictionary<string, object>?> GenerateAndReceiveEncryptionChallenge(
        IQueryProcessor queryProcessor,
        HttpClient client,
        RpgDbContext rpgDbContext
    )
    {
        // arrange
        var (mockedPublicAppPEM, mockedPrivateAppPEM) = GetPEMPairForMockedApp();
        var encryptedAppPubKey = await new RSAEncryptStringQuery { StringToEncrypt = mockedPublicAppPEM }
            .RunAsync(queryProcessor, default!)
            .ConfigureAwait(true);

        // Act
        var response = await client.PostAsync(
            "/register/createencryptionchallenge",
            new StringContent($"\"{encryptedAppPubKey.Get()}\"", Encoding.UTF8, "application/json")
        );

        // Assert
        response.StatusCode.Should().Be(System.Net.HttpStatusCode.OK);

        var encryptedContent = await response.Content.ReadAsStringAsync();
        encryptedContent.Should().NotBeNull();

        var decryptedChallenge = await new RSADecryptStringQuery
        {
            StringToDecrypt = encryptedContent,
            PrivateKeyOverride = mockedPrivateAppPEM,
        }
            .RunAsync(queryProcessor, default!)
            .ConfigureAwait(true);

        decryptedChallenge.IsSome.Should().BeTrue();

        // should be a dictionary
        var challengeDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(decryptedChallenge.Get());

        // check if encryption challenge was successfully added to database
        var entities = rpgDbContext.EncryptionChallenges.ToList();
        entities.Count.Should().Be(1);
        entities[0].Id.ToString().Should().Be(challengeDict!["id"].ToString());
        entities[0].PasswordPrefix.ToString().Should().Be(challengeDict["pp"].ToString());
        entities[0].RndInt.ToString().Should().Be(challengeDict["ri"].ToString());

        return challengeDict;
    }

    private static (string mockedPublicAppPEM, string mockedPrivateAppPEM) GetPEMPairForMockedApp()
    {
        // some mocked 1024byte strong rsa certs
        return (
            "-----BEGIN PUBLIC KEY-----MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgHLeHzeVyXHmHjGDTgQIBBN4G2IVI4Ecta7JOGNUqU29+mA+w8lS6k/HkW0vXZV7AJpSjeC10ZwvWqtjwPQ7xxdNgofl8ezy/QqlCxntYJq8lRn4CFcJi8uzbHYCp1DVxtUOdx/9vsYUKT2QiOtCL5/m23wDmTp4yxkeXWx2xm6rAgMBAAE=-----END PUBLIC KEY-----",
            "-----BEGIN RSA PRIVATE KEY-----MIICWgIBAAKBgHLeHzeVyXHmHjGDTgQIBBN4G2IVI4Ecta7JOGNUqU29+mA+w8lS6k/HkW0vXZV7AJpSjeC10ZwvWqtjwPQ7xxdNgofl8ezy/QqlCxntYJq8lRn4CFcJi8uzbHYCp1DVxtUOdx/9vsYUKT2QiOtCL5/m23wDmTp4yxkeXWx2xm6rAgMBAAECgYAI+VF3Bjy2qUOymo99wSKQYtHA1+XuMFABV7cQC40uhakJ291v3QpxMSYrYYfuJa3mYIy1AX9etFRhD2oDqqfjD1+kO9kA/9wKNmknA/ZPRsr0V1p4l2O+vz+TdOp4818CPBbQKfSsu+0gE7mvjh94Y6/uyduYV44CH7HNvNEgAQJBAKzU9E5vlrEsxREBHJdbBVjNVesq25FSLlVNZpB9ytiXFvkY7GTVe/9Jm1SrWSpVHY9XEJtcDqRnycwfIPtgo/0CQQCqJJieDBg2wvfbEh5HwWvvRM8ihkj6AhueNIZr3aFL/Q/ttzBb3o4NLjvKk86As8iVgEu3uELfRTnWDAXzdFnHAkAUHcVBy+MyRA+75vE4/LMmnt+9O4PK6lHSQ+wILVwK0asu2yPIqMCB+kNGG5uJPdbu9CdOrexWXm4yf/0KxTjRAkB2Nw0vKtocGmUZ+kG9u39h9J4yr7i+tH458ua+xXPPl1nc4d4gxsZOFCSJAR+GvuOMNGLnmIgmFzQzK5Fq8Rl7AkBVZC5f2WzOWP4Psf+VnGZgf6cSrkBJploIt5Ryk2/ENVXPr1AYeFmnB983BfwOxr50HhXOlLk/gZzUmj9uDl25-----END RSA PRIVATE KEY-----"
        );
    }
}
