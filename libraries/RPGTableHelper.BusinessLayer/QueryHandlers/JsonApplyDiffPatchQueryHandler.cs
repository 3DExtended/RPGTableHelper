using System.Text.Json;
using System.Text.Json.Nodes;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;
using RPGTableHelper.BusinessLayer.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.QueryHandlers;

public class JsonApplyDiffPatchQueryHandler : IQueryHandler<JsonApplyDiffPatchQuery, JsonNode>
{
    public IQueryHandler<JsonApplyDiffPatchQuery, JsonNode> Successor { get; set; } = null!;

    public Task<Option<JsonNode>> RunQueryAsync(JsonApplyDiffPatchQuery query, CancellationToken cancellationToken)
    {
        if (query == null)
        {
            throw new ArgumentNullException(nameof(query));
        }

        if (query.OriginalJson == null)
        {
            throw new ArgumentException("Original JSON must be provided");
        }

        if (
            query.PatchRequest == null
            || query.PatchRequest.Operations == null
            || query.PatchRequest.Operations.Count == 0
        )
        {
            throw new ArgumentException("Patch request must contain operations");
        }

        var originalJson = query.OriginalJson;
        var operations = query.PatchRequest.Operations;

        var result = JsonDiffer.Apply(originalJson, operations);

        return Task.FromResult<Option<JsonNode>>(result);
    }
}
