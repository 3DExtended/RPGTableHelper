using System.Text.Json.Nodes;
using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace RPGTableHelper.WebApi.Swagger
{
    public class EnumSchemaFilter : ISchemaFilter
    {
        public void Apply(IOpenApiSchema schema, SchemaFilterContext context)
        {
            if (!context.Type.IsEnum || schema is not OpenApiSchema openApiSchema)
            {
                return;
            }

            openApiSchema.Enum?.Clear();
            foreach (var n in Enum.GetNames(context.Type))
            {
                openApiSchema.Enum?.Add(JsonValue.Create(n));
            }

            openApiSchema.Type = JsonSchemaType.String;
            openApiSchema.Format = null;
        }
    }
}
