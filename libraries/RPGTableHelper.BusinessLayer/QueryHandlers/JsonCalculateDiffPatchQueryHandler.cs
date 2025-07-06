using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Nodes;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.BusinessLayer.Contracts.Models;
using RPGTableHelper.BusinessLayer.Contracts.Queries;

namespace RPGTableHelper.BusinessLayer.QueryHandlers;

public class JsonCalculateDiffPatchQueryHandler : IQueryHandler<JsonCalculateDiffPatchQuery, JsonPatchRequest>
{
    public IQueryHandler<JsonCalculateDiffPatchQuery, JsonPatchRequest> Successor { get; set; } = default!;

    public Task<Option<JsonPatchRequest>> RunQueryAsync(
        JsonCalculateDiffPatchQuery query,
        CancellationToken cancellationToken
    )
    {
        if (query == null)
        {
            throw new ArgumentNullException(nameof(query));
        }

        if (string.IsNullOrWhiteSpace(query.OriginalJson) || string.IsNullOrWhiteSpace(query.ModifiedJson))
        {
            throw new ArgumentException("Original and modified JSON must be provided");
        }

        var oldJson = JsonNode.Parse(query.OriginalJson) ?? throw new Exception("Invalid original JSON");
        var newJson = JsonNode.Parse(query.ModifiedJson) ?? throw new Exception("Invalid modified JSON");

        var patches = JsonDiffer.Diff(oldJson, newJson);

        return Task.FromResult<Option<JsonPatchRequest>>(
            new JsonPatchRequest
            {
                Operations = patches.ConvertAll(patch => new JsonObject
                {
                    ["op"] = patch["op"],
                    ["path"] = patch["path"],
                    ["value"] = patch["value"],
                }),
            }
        );
    }
}
