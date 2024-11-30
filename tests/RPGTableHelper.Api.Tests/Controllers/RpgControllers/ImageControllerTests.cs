using System.Net;
using System.Net.Http.Headers;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using RPGTableHelper.Api.Tests.Base;
using RPGTableHelper.DataLayer.Tests.QueryHandlers;
using RPGTableHelper.WebApi;

namespace RPGTableHelper.Api.Tests.Controllers.RpgControllers;

public class ImageControllerTests
{
    public class StreamImageUploadTests : ControllerTestBase
    {
        private const long MaxFileSize = 10 * 1024 * 1024; // 10 MB

        private const string UploadUrl = "/image/streamimageupload"; // Adjust with the actual endpoint URL.

        public StreamImageUploadTests(WebApplicationFactory<Program> factory)
            : base(factory) { }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnOk_WhenValidImageIsUploaded()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var fileContent = new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 }; // Example JPEG file content.
            using var fileStream = new MemoryStream(fileContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            using var formData = new MultipartFormDataContent { { content, "image", "test.jpg" } };

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var urlForImage = await response.Content.ReadAsStringAsync();
            urlForImage.Should().NotBeNullOrWhiteSpace();
            urlForImage.Should().Contain("/public/getimage/");
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenFileSizeExceedsLimit()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var oversizedContent = new byte[MaxFileSize + 1];
            using var fileStream = new MemoryStream(oversizedContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            using var formData = new MultipartFormDataContent { { content, "image", "oversized.jpg" } };

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            var errorMessage = await response.Content.ReadAsStringAsync();
            errorMessage.Should().Contain("File size exceeds the maximum limit");
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenFileIsEmpty()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            using var fileStream = new MemoryStream();
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            using var formData = new MultipartFormDataContent { { content, "image", "empty.jpg" } };

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            var errorMessage = await response.Content.ReadAsStringAsync();
            errorMessage.Should().Contain("File size is 0 MB");
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenInvalidFileTypeIsUploaded()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var invalidContent = new byte[] { 0x00, 0x01, 0x02, 0x03 }; // Example non-image content.
            using var fileStream = new MemoryStream(invalidContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("text/plain");
            using var formData = new MultipartFormDataContent { { content, "image", "test.txt" } };

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            var errorMessage = await response.Content.ReadAsStringAsync();
            errorMessage.Should().Contain("Invalid file type");
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenInvalidMimeTypeIsUploaded()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var invalidContent = new byte[] { 0x89, 0x50, 0x4E, 0x47 }; // Example PNG file content.
            using var fileStream = new MemoryStream(invalidContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("text/plain");
            using var formData = new MultipartFormDataContent { { content, "image", "test.png" } };

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            var errorMessage = await response.Content.ReadAsStringAsync();
            errorMessage.Should().Contain("Invalid MIME type");
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnUnauthorized_WhenUserNotInCampagne()
        {
            // arrange
            var user = await RpgDbContextHelpers.CreateUserInDb(ContextFactory!, Mapper!);
            var nonMemberCampagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var fileContent = new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 };
            using var fileStream = new MemoryStream(fileContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            using var formData = new MultipartFormDataContent { { content, "image", "test.jpg" } };

            var requestUri = $"{UploadUrl}?campagneId={nonMemberCampagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenFileIsMissing()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            using var formData = new MultipartFormDataContent(); // No file included.

            var requestUri = $"{UploadUrl}?campagneId={campagne.Id.Value}";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        [Fact]
        public async Task StreamUploadImage_ShouldReturnBadRequest_WhenCampagneIdIsInvalid()
        {
            // arrange
            var user = await ConfigureLoggedInUser();
            var campagne = await RpgDbContextHelpers.CreateCampagneInDb(ContextFactory!, Mapper!, user);

            var fileContent = new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 };
            using var fileStream = new MemoryStream(fileContent);
            var content = new StreamContent(fileStream);
            content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            using var formData = new MultipartFormDataContent { { content, "image", "test.jpg" } };

            var requestUri = $"{UploadUrl}?campagneId=invalid-guid";

            // act
            var response = await Client.PostAsync(requestUri, formData);

            // assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }
    }
}
