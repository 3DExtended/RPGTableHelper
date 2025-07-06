using System.Text.Json.Nodes;

namespace RPGTableHelper.BusinessLayer.Contracts.Models;

public class JsonPatchRequest
{
    public List<JsonObject> Operations { get; set; } = new List<JsonObject>();
}
