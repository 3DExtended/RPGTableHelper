using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;

namespace RPGTableHelper.BusinessLayer.Contracts.Queries
{
    public class JsonCalculateDiffPatchQuery : IQuery<JsonPatchRequest, JsonCalculateDiffPatchQuery>
    {
        public string OriginalJson { get; set; } = default!;
        public string ModifiedJson { get; set; } = default!;
    }
}
