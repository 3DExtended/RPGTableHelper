namespace RPGTableHelper.WebApi.Dtos
{
    /// <summary>
    /// Represents a data transfer object for encapsulating encrypted messages.
    /// </summary>
    public class EncryptedMessageWrapperDto
    {
        public string EncryptedMessage { get; set; } = default!;
    }
}
