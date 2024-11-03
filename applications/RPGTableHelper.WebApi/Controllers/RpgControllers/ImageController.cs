using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
        private readonly IUserContext _userContext;
        private readonly IQueryProcessor _queryProcessor;

        public ImageController(IUserContext userContext, IQueryProcessor queryProcessor)
        {
            _queryProcessor = queryProcessor;
            _userContext = userContext;
        }

        [HttpPost("generateimage/{campagneid}")]
        public async Task<ActionResult<string>> GetOpenAIImageForQuery(
            [FromBody] string prompt,
            [FromRoute] string campagneid,
            CancellationToken cancellationToken
        )
        {
            var isUserInCampagne = await new CampagneIsUserInCampagneQuery
            {
                UserIdToCheck = _userContext.User.UserIdentifier,
                CampagneId = Campagne.CampagneIdentifier.From(Guid.Parse(campagneid)),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagne.IsNone || !isUserInCampagne.Get())
            {
                return BadRequest();
            }

            var imageGenerationResult = await new AiGenerateImageQuery { ImagePrompt = prompt }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (imageGenerationResult.IsNone)
            {
                return BadRequest();
            }

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
                Stream = imageGenerationResult.Get(),
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (saveLocallyResult.IsNone)
            {
                return BadRequest();
            }

            await imageGenerationResult.Get().DisposeAsync().ConfigureAwait(false);

            var urlForImage = $"/public/getimage/{newMetadata.Id.Value}/{apikey}";
            return Ok(urlForImage);
        }
    }
}
