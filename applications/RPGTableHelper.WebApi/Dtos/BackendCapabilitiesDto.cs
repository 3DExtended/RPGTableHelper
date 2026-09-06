namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Advertises the optional features this backend supports so that a newer
    /// frontend can degrade gracefully when talking to an older backend (and
    /// vice versa). The list is purely additive: capabilities are only ever
    /// added, never removed, and a missing endpoint (older backend) is treated
    /// by the client as "baseline capabilities only".
    /// </summary>
    public class BackendCapabilitiesDto
    {
        /// <summary>
        /// Gets or sets the stable capability identifiers this backend supports
        /// (e.g. "character-image-upload").
        /// </summary>
        public IReadOnlyList<string> Capabilities { get; set; } = new List<string>();

        /// <summary>
        /// Gets or sets the semantic api version of this backend, for
        /// diagnostics/logging on the client.
        /// </summary>
        public string ApiVersion { get; set; } = default!;
    }
}
