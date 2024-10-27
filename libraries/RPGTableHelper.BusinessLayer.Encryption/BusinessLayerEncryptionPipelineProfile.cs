using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer.Encryption
{
    /// <summary>
    /// Represents a profile for registering encryption business layer pipelines in the CQRS system.
    /// </summary>
    public class BusinessLayerEncryptionPipelineProfile : IPipelineProfile
    {
        /// <summary>
        /// Registers the data layer-specific pipelines.
        /// </summary>
        /// <param name="registerFunction">The function used to register pipelines.</param>
        public void RegisterPipelines(Action<Pipeline> registerFunction)
        {
            // Register your data layer pipelines here
            // Example:
            // registerFunction(
            //        new PipelineBuilder<GenericQuery<string>, string>()
            //            .With<GenericQueryHandler<GenericQuery<string>, string>>()
            //            .Build()
            //    );
        }
    }
}
