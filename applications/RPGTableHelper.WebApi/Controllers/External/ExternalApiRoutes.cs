namespace RPGTableHelper.WebApi.Controllers.External
{
    /// <summary>
    /// Route prefixes of the external player API. Every external controller is reachable under
    /// <see cref="V1"/>; the read endpoints that existed before v1 additionally keep <see cref="Legacy"/>.
    /// </summary>
    public static class ExternalApiRoutes
    {
        public const string V1 = "api/external/v1";

        /// <summary>Pre-v1 prefix, kept as a read-only alias and hidden from the API docs.</summary>
        public const string Legacy = "api/external";

        public const string SwaggerGroupName = "external";
    }
}
