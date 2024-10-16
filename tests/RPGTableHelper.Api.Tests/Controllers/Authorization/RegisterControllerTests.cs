using System.Text;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Queries;
using RPGTableHelper.WebApi;
using RPGTableHelper.WebApi.Controllers;

namespace RPGTableHelper.Shared.Tests.Controllers.Authorization;

public class RegisterControllerTests : ControllerTestBase
{
    public RegisterControllerTests(WebApplicationFactory<Program> factory)
        : base(factory) { }

    [Fact]
    public async Task CreateNewChallenge_ShouldSuccessfullyGenerateNewChallengeAndUseRSAEncryption()
    {
        // Act
        var (mockedPublicAppPEM, mockedPrivateAppPEM) = GetPEMPairForMockedApp();

        var encryptedAppPubKey = await new RSAEncryptStringQuery
        {
            StringToEncrypt = mockedPublicAppPEM,
        }
            .RunAsync(QueryProcessor, (default!))
            .ConfigureAwait(true);

        var response = await _client.PostAsync(
            "/register/registerchallenge",
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
            .RunAsync(QueryProcessor, (default!))
            .ConfigureAwait(true);

        decryptedChallenge.IsSome.Should().BeTrue();

        // should be a dictionary
        var challengeDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(
            decryptedChallenge.Get()
        );

        // check if encryption challenge was successfully added to database
        var entities = Context.EncryptionChallenges.ToList();
        entities.Count.Should().Be(1);
        entities[0].Id.ToString().Should().Be(challengeDict["id"].ToString());
        entities[0].PasswordPrefix.ToString().Should().Be(challengeDict["pp"].ToString());
        entities[0].RndInt.ToString().Should().Be(challengeDict["ri"].ToString());
    }

    private (string mockedPublicAppPEM, string mockedPrivateAppPEM) GetPEMPairForMockedApp()
    {
        // some mocked 1024byte strong rsa certs
        return (
            "-----BEGIN PUBLIC KEY-----MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgHLeHzeVyXHmHjGDTgQIBBN4G2IVI4Ecta7JOGNUqU29+mA+w8lS6k/HkW0vXZV7AJpSjeC10ZwvWqtjwPQ7xxdNgofl8ezy/QqlCxntYJq8lRn4CFcJi8uzbHYCp1DVxtUOdx/9vsYUKT2QiOtCL5/m23wDmTp4yxkeXWx2xm6rAgMBAAE=-----END PUBLIC KEY-----",
            "-----BEGIN RSA PRIVATE KEY-----MIICWgIBAAKBgHLeHzeVyXHmHjGDTgQIBBN4G2IVI4Ecta7JOGNUqU29+mA+w8lS6k/HkW0vXZV7AJpSjeC10ZwvWqtjwPQ7xxdNgofl8ezy/QqlCxntYJq8lRn4CFcJi8uzbHYCp1DVxtUOdx/9vsYUKT2QiOtCL5/m23wDmTp4yxkeXWx2xm6rAgMBAAECgYAI+VF3Bjy2qUOymo99wSKQYtHA1+XuMFABV7cQC40uhakJ291v3QpxMSYrYYfuJa3mYIy1AX9etFRhD2oDqqfjD1+kO9kA/9wKNmknA/ZPRsr0V1p4l2O+vz+TdOp4818CPBbQKfSsu+0gE7mvjh94Y6/uyduYV44CH7HNvNEgAQJBAKzU9E5vlrEsxREBHJdbBVjNVesq25FSLlVNZpB9ytiXFvkY7GTVe/9Jm1SrWSpVHY9XEJtcDqRnycwfIPtgo/0CQQCqJJieDBg2wvfbEh5HwWvvRM8ihkj6AhueNIZr3aFL/Q/ttzBb3o4NLjvKk86As8iVgEu3uELfRTnWDAXzdFnHAkAUHcVBy+MyRA+75vE4/LMmnt+9O4PK6lHSQ+wILVwK0asu2yPIqMCB+kNGG5uJPdbu9CdOrexWXm4yf/0KxTjRAkB2Nw0vKtocGmUZ+kG9u39h9J4yr7i+tH458ua+xXPPl1nc4d4gxsZOFCSJAR+GvuOMNGLnmIgmFzQzK5Fq8Rl7AkBVZC5f2WzOWP4Psf+VnGZgf6cSrkBJploIt5Ryk2/ENVXPr1AYeFmnB983BfwOxr50HhXOlLk/gZzUmj9uDl25-----END RSA PRIVATE KEY-----"
        );
    }
}
