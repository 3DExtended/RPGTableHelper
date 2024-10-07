using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.SendGrid
{
    /// <summary>
    /// Represents a profile for registering data layer pipelines in the CQRS system.
    /// </summary>
    public class DataLayerSendGridPipelineProfile : IPipelineProfile
    {
        /// <summary>
        /// Registers the sendgrid data layer-specific pipelines.
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
