namespace RPGTableHelper.DataLayer.OpenAI.Contracts.Options
{
    public class OpenAIOptions
    {
        /// <summary>
        /// OpenAI API key from https://platform.openai.com (required for image generation).
        /// </summary>
        public string? ApiKey { get; set; }

        /// <summary>
        /// Optional override for the OpenAI API base URL (e.g. https://api.openai.com/v1).
        /// When null or empty, the SDK default is used.
        /// </summary>
        public string? OpenAIUrl { get; set; }

        /// <summary>
        /// Model id for <c>images/generations</c> (e.g. gpt-image-1, gpt-image-1-mini). Defaults to gpt-image-1 when unset.
        /// </summary>
        public string? ImageModel { get; set; }
    }
}
