using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.QueryHandlers.Users;

namespace RPGTableHelper.DataLayer
{
    /// <summary>
    /// Represents a profile for registering data layer pipelines in the CQRS system.
    /// </summary>
    public class DataLayerPipelineProfile : IPipelineProfile
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
