using System.Text.Json;
using System.Text.Json.Nodes;

namespace RPGTableHelper.BusinessLayer.QueryHandlers;

public static class JsonDiffer
{
    public static List<JsonObject> Diff(JsonNode oldJson, JsonNode newJson)
    {
        var patches = new List<JsonObject>();

        int oldVersion = oldJson?["version"]?.GetValue<int>() ?? throw new Exception("Old JSON must have version");
        int newVersion = newJson?["version"]?.GetValue<int>() ?? throw new Exception("New JSON must have version");

        if (oldVersion == newVersion)
        {
            throw new Exception("Versions must differ for a valid patch");
        }

        // Add version update
        patches.Add(
            new JsonObject
            {
                ["op"] = "version",
                ["from"] = oldVersion,
                ["to"] = newVersion,
            }
        );

        GenerateDiff(oldJson, newJson, string.Empty, patches);

        // remove patches for version
        patches.RemoveAll(p => p["op"]?.ToString() == "replace" && p["path"]?.ToString() == "/version");

        return patches;
    }

    public static JsonNode Apply(JsonNode original, List<JsonObject> operations)
    {
        if (operations == null || operations.Count == 0)
        {
            throw new Exception("Empty patch");
        }

        var versionOp = operations[0];
        if (versionOp["op"]?.ToString() != "version")
        {
            throw new Exception("First operation must be a version update");
        }

        int expectedVersion = versionOp["from"]?.GetValue<int>() ?? throw new Exception("Missing version 'from'");
        int targetVersion = versionOp["to"]?.GetValue<int>() ?? throw new Exception("Missing version 'to'");

        if (original?["version"]?.GetValue<int>() != expectedVersion)
        {
            throw new Exception($"Version mismatch. Expected {expectedVersion}");
        }

        var result = original?.DeepClone() ?? new JsonObject();

        foreach (var op in operations.Skip(1))
        {
            string opType = op["op"]?.ToString() ?? throw new Exception("Missing op type");
            string path = op["path"]?.ToString() ?? throw new Exception("Missing path");

            ApplyOperation(result, opType, path, op);
        }

        result["version"] = targetVersion;
        return result!;
    }

    private static void ApplyOperation(JsonNode? root, string op, string path, JsonNode opData)
    {
        var parts = path.Trim('/').Split('/');
        var current = root;

        for (int i = 0; i < parts.Length - 1; i++)
        {
            if (current is JsonObject obj)
            {
                current = obj[parts[i]];
            }
            else if (current is JsonArray arr && int.TryParse(parts[i], out int index) && index < arr.Count)
            {
                current = arr[index];
            }
            else
            {
                throw new Exception($"Invalid path: {path}");
            }
        }

        var lastPart = parts[^1];

        if (current is JsonObject parentObj)
        {
            switch (op)
            {
                case "add":
                case "replace":
                    parentObj[lastPart] = opData["value"]!.DeepClone();
                    break;
                case "remove":
                    parentObj.Remove(lastPart);
                    break;
                default:
                    throw new Exception($"Unsupported op: {op}");
            }
        }
        else if (current is JsonArray parentArr)
        {
            if (!int.TryParse(lastPart, out int index))
            {
                throw new Exception($"Invalid array index: {lastPart}");
            }

            switch (op)
            {
                case "add":
                    if (index > parentArr.Count)
                    {
                        throw new Exception($"Invalid add index: {index}");
                    }

                    parentArr.Insert(index, opData["value"]!.DeepClone());
                    break;
                case "replace":
                    if (index >= parentArr.Count)
                    {
                        throw new Exception($"Invalid replace index: {index}");
                    }

                    parentArr[index] = opData["value"]!.DeepClone();
                    break;
                case "remove":
                    if (index >= parentArr.Count)
                    {
                        throw new Exception($"Invalid remove index: {index}");
                    }

                    parentArr.RemoveAt(index);
                    break;
                default:
                    throw new Exception($"Unsupported op: {op}");
            }
        }
        else
        {
            throw new Exception($"Unsupported parent type for path: {path}");
        }
    }

    private static void GenerateDiff(JsonNode? oldNode, JsonNode? newNode, string path, List<JsonObject> patches)
    {
        if (oldNode is JsonObject oldObj && newNode is JsonObject newObj)
        {
            foreach (var prop in oldObj)
            {
                if (!newObj.ContainsKey(prop.Key))
                {
                    patches.Add(new JsonObject { ["op"] = "remove", ["path"] = $"{path}/{prop.Key}" });
                }
                else
                {
                    GenerateDiff(prop.Value, newObj[prop.Key], $"{path}/{prop.Key}", patches);
                }
            }

            foreach (var prop in newObj)
            {
                if (!oldObj.ContainsKey(prop.Key))
                {
                    patches.Add(
                        new JsonObject
                        {
                            ["op"] = "add",
                            ["path"] = $"{path}/{prop.Key}",
                            ["value"] = prop.Value!.DeepClone(),
                        }
                    );
                }
            }
        }
        else if (oldNode is JsonArray oldArr && newNode is JsonArray newArr)
        {
            int commonLength = Math.Min(oldArr.Count, newArr.Count);
            for (int i = 0; i < commonLength; i++)
            {
                GenerateDiff(oldArr[i], newArr[i], $"{path}/{i}", patches);
            }

            for (int i = commonLength; i < newArr.Count; i++)
            {
                patches.Add(
                    new JsonObject
                    {
                        ["op"] = "add",
                        ["path"] = $"{path}/{i}",
                        ["value"] = newArr[i]!.DeepClone(),
                    }
                );
            }

            for (int i = oldArr.Count - 1; i >= newArr.Count; i--)
            {
                patches.Add(new JsonObject { ["op"] = "remove", ["path"] = $"{path}/{i}" });
            }
        }
        else if (!JsonNode.DeepEquals(oldNode, newNode))
        {
            patches.Add(
                new JsonObject
                {
                    ["op"] = "replace",
                    ["path"] = path,
                    ["value"] = newNode!.DeepClone(),
                }
            );
        }
    }
}
