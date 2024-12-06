namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities
{
    public class TextBlock : NoteBlockModelBase
    {
        public string MarkdownText { get; set; } = default!;
    }
}
