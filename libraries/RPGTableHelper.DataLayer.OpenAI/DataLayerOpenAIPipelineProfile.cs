using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.OpenAI
{
    public class DataLayerOpenAIPipelineProfile : IPipelineProfile
    {
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
