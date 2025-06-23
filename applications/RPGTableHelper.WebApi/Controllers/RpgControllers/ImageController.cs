using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MimeDetective;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.OpenAI.Contracts.Queries;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Controllers.RpgControllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class ImageController : ControllerBase
    {
        private const long MaxFileSize = 10 * 1024 * 1024; // 10 MB

        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;

        public ImageController(IUserContext userContext, IQueryProcessor queryProcessor)
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
        }

        [HttpPost("generateimage/{campagneid}")]
        public async Task<ActionResult<string>> GetOpenAIImageForQuery(
            [FromBody] [Required] string prompt,
            [FromRoute] string campagneid,
            CancellationToken cancellationToken
        )
        {
            if (!Guid.TryParse(campagneid, out var campagneGuid))
            {
                return BadRequest("Invalid campagne ID format.");
            }

            var isUserInCampagne = await new CampagneIsUserInCampagneQuery
            {
                UserIdToCheck = _userContext.User.UserIdentifier,
                CampagneId = Campagne.CampagneIdentifier.From(campagneGuid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagne.IsNone || !isUserInCampagne.Get())
            {
                return Unauthorized();
            }

            var imageGenerationResult = await new AiGenerateImageQuery { ImagePrompt = prompt }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageGenerationResult.IsNone)
            {
                return BadRequest("Image generation failed. Please try again.");
            }

            await using var imageGenerationResultContent = imageGenerationResult.Get();

            var apikey = ApiKeyGenerator.GenerateKey(32);
            var newMetadata = new ImageMetaData
            {
                CreatedForCampagneId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneid)),
                CreatorId = _userContext.User.UserIdentifier,
                ApiKey = apikey,
                ImageType = ImageType.PNG,
                LocallyStored = true,
            };

            var metadata = await new ImageMetaDataCreateQuery { ModelToCreate = newMetadata }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (metadata.IsNone)
            {
                return BadRequest();
            }

            newMetadata.Id = metadata.Get();

            var saveLocallyResult = await new ImageSaveQuery
            {
                MetaData = newMetadata,
                Stream = imageGenerationResultContent,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (saveLocallyResult.IsNone)
            {
                return BadRequest();
            }

            var urlForImage = $"/public/getimage/{newMetadata.Id.Value}/{apikey}?metadataid={newMetadata.Id.Value}";
            return Ok(urlForImage);
        }

        /// <summary>
        /// Streams an image upload directly to the server.
        /// </summary>
        /// <returns>Returns the status of the upload.</returns>
        /// <response code="200">The image was uploaded successfully.</response>
        /// <response code="400">Invalid image or file size exceeded the limit.</response>
        /// <response code="500">Server error while processing the file.</response>
        [HttpPost("streamimageupload")]
        [ProducesResponseType(typeof(string), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(500)]
        public async Task<IActionResult> StreamUploadImage(
            [FromQuery] [Required] string campagneId,
            IFormFile image,
            CancellationToken cancellationToken
        )
        {
            HttpRequestRewindExtensions.EnableBuffering(Request);

            if (!Guid.TryParse(campagneId, out var campagneIdParsed))
            {
                return BadRequest($"Campagne Id is malformed");
            }

            if (image.Length > MaxFileSize)
            {
                return BadRequest($"File size exceeds the maximum limit of {MaxFileSize / (1024 * 1024)} MB.");
            }

            if (image.Length == 0)
            {
                return BadRequest($"File size is 0 MB.");
            }

            var permittedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(image.FileName).ToLowerInvariant();

            if (string.IsNullOrEmpty(extension) || !permittedExtensions.Contains(extension))
            {
                return BadRequest($"Invalid file type.");
            }

            // Optional: Validate MIME type as well
            var mimeType = image.ContentType;
            var permittedMimeTypes = new[] { "image/jpeg", "image/jpg", "image/png" };
            if (!permittedMimeTypes.Contains(mimeType))
            {
                return BadRequest("Invalid MIME type.");
            }

            var isUserInCampagne = await new CampagneIsUserInCampagneQuery
            {
                UserIdToCheck = _userContext.User.UserIdentifier,
                CampagneId = Campagne.CampagneIdentifier.From(campagneIdParsed),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagne.IsNone || !isUserInCampagne.Get())
            {
                return Unauthorized();
            }

            // var mimeType = await GetMimeTypeFromStreamAsync(Request.Body);
            var apikey = ApiKeyGenerator.GenerateKey(32);
            var newMetadata = new ImageMetaData
            {
                CreatedForCampagneId = Campagne.CampagneIdentifier.From(campagneIdParsed),
                CreatorId = _userContext.User.UserIdentifier,
                ApiKey = apikey,
                ImageType = mimeType switch
                {
                    "image/jpeg" => ImageType.JPEG,
                    "image/jpg" => ImageType.JPEG,
                    "image/png" => ImageType.PNG,
                    _ => throw new NotImplementedException(),
                },
                LocallyStored = true,
            };

            var metadata = await new ImageMetaDataCreateQuery { ModelToCreate = newMetadata }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (metadata.IsNone)
            {
                return BadRequest();
            }

            newMetadata.Id = metadata.Get();

            // Do some processing with body…
            await using var imageStream = image.OpenReadStream();

            var saveResult = await new ImageSaveQuery { Stream = imageStream, MetaData = newMetadata }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (saveResult.IsNone)
            {
                return BadRequest();
            }

            var urlForImage = $"/public/getimage/{newMetadata.Id.Value}/{apikey}?metadataid={newMetadata.Id.Value}";
            return Ok(urlForImage);
        }

        /// <summary>
        /// Returns all images (their metadata urls) for a specific campagne where the creator is the requesting user.
        /// </summary>
        /// <param name="campagneId">The ID of the campagne to retrieve images for.</param>
        /// <returns>A list of image metadata URLs.</returns>
        [HttpGet("getimages/{campagneId}")]
        [ProducesResponseType(typeof(IEnumerable<ImageMetaData>), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(500)]
        public async Task<IActionResult> GetImagesForCampagne(
            [FromRoute] string campagneId,
            CancellationToken cancellationToken
        )
        {
            if (!Guid.TryParse(campagneId, out var campagneGuid))
            {
                return BadRequest("Invalid campagne ID format.");
            }

            if (campagneGuid == Guid.Empty)
            {
                return BadRequest("Campagne ID cannot be empty.");
            }

            var isUserInCampagne = await new CampagneIsUserInCampagneQuery
            {
                UserIdToCheck = _userContext.User.UserIdentifier,
                CampagneId = Campagne.CampagneIdentifier.From(campagneGuid),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagne.IsNone || !isUserInCampagne.Get())
            {
                return Unauthorized();
            }

            var images = await new ImageMetaDatasQuery
            {
                CampagneIdentifier = Campagne.CampagneIdentifier.From(campagneGuid),
                RequestingUserIdentifier = _userContext.User.UserIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (images.IsNone)
            {
                return BadRequest("No images found for the specified campagne.");
            }

            return Ok(images.Get().OrderByDescending(img => img.CreationDate).ToList());
        }

        /// <summary>
        /// Reads the header of different image formats
        /// </summary>
        /// <returns>true if valid file signature (magic number/header marker) is found</returns>
        private static bool IsValidImageStream(Stream stream)
        {
            byte[] headerBytes = new byte[8];
            byte[] trailerBytes = new byte[2];

            var bmp = new byte[] { 0x42, 0x4D }; // BMP "BM"
            var gif87a = new byte[] { 0x47, 0x49, 0x46, 0x38, 0x37, 0x61 }; // "GIF87a"
            var gif89a = new byte[] { 0x47, 0x49, 0x46, 0x38, 0x39, 0x61 }; // "GIF89a"
            var png = new byte[] { 0x89, 0x50, 0x4e, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }; // PNG "\x89PNG\x0D\0xA\0x1A\0x0A"
            var tiffI = new byte[] { 0x49, 0x49, 0x2A, 0x00 }; // TIFF II "II\x2A\x00"
            var tiffM = new byte[] { 0x4D, 0x4D, 0x00, 0x2A }; // TIFF MM "MM\x00\x2A"
            var jpeg = new byte[] { 0xFF, 0xD8, 0xFF }; // JPEG JFIF (SOI "\xFF\xD8" and half next marker xFF)
            var jpegEnd = new byte[] { 0xFF, 0xD9 }; // JPEG EOI "\xFF\xD9"

            try
            {
                // Read the first few bytes
                stream.Seek(0, SeekOrigin.Begin);
                stream.Read(headerBytes, 0, headerBytes.Length);

                // Check file trailer for JPEG (read last 2 bytes)
                if (stream.Length > trailerBytes.Length)
                {
                    stream.Seek(-trailerBytes.Length, SeekOrigin.End);
                    stream.Read(trailerBytes, 0, trailerBytes.Length);
                }

                stream.Seek(0, SeekOrigin.Begin); // Reset stream position for further operations

                // Validate the header
                if (
                    ByteArrayStartsWith(headerBytes, bmp)
                    || ByteArrayStartsWith(headerBytes, gif87a)
                    || ByteArrayStartsWith(headerBytes, gif89a)
                    || ByteArrayStartsWith(headerBytes, png)
                    || ByteArrayStartsWith(headerBytes, tiffI)
                    || ByteArrayStartsWith(headerBytes, tiffM)
                )
                {
                    return true;
                }

                // Additional validation for JPEG
                if (ByteArrayStartsWith(headerBytes, jpeg) && ByteArrayStartsWith(trailerBytes, jpegEnd))
                {
                    return true;
                }
            }
            catch (Exception)
            {
                // asdf
            }

            return false;
        }

        /// <summary>
        /// Returns a value indicating whether a specified subarray occurs within array
        /// </summary>
        /// <param name="a">Main array</param>
        /// <param name="b">Subarray to seek within main array</param>
        /// <returns>true if a array starts with b subarray or if b is empty; otherwise false</returns>
        private static bool ByteArrayStartsWith(byte[] a, byte[] b)
        {
            if (a.Length < b.Length)
            {
                return false;
            }

            for (int i = 0; i < b.Length; i++)
            {
                if (a[i] != b[i])
                {
                    return false;
                }
            }

            return true;
        }

        private static async Task<string?> GetMimeTypeFromStreamAsync(Stream stream)
        {
            var inspector = new ContentInspectorBuilder()
            {
                Definitions = MimeDetective.Definitions.Default.All(),
            }.Build();

            var contentInfo = inspector.Inspect(stream).ByMimeType();
            if (contentInfo.Count() == 1)
            {
                return contentInfo.First().MimeType;
            }

            return null;
        }
    }
}
