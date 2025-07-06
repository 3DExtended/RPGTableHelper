using System.Text.Json.Nodes;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;

namespace RPGTableHelper.BusinessLayer.Contracts.Queries
{
    public class JsonApplyDiffPatchQuery : IQuery<JsonNode, JsonApplyDiffPatchQuery>
    {
        public JsonNode OriginalJson { get; set; } = default!;
        public JsonPatchRequest PatchRequest { get; set; } = new JsonPatchRequest();
    }
}
