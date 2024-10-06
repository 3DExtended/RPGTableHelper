using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.BusinessLayer
{
    public class BusinessLayerPipelineProfile : IPipelineProfile
    {
        public void RegisterPipelines(Action<Pipeline> registerFunction) { }
    }
}
