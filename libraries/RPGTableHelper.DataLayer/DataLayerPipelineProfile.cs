using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer
{
    public class DataLayerPipelineProfile : IPipelineProfile
    {
        public void RegisterPipelines(Action<Pipeline> registerFunction) { }
    }
}
