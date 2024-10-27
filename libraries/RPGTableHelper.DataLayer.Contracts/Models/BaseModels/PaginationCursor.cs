namespace RPGTableHelper.DataLayer.Contracts.Models.BaseModels
{
    public enum PaginationCursorDirection
    {
        Before, // newer
        After, // later
    }

    public class PaginationCursor
    {
        public string Base64EncodedCursor { get; set; } = default!;

        public PaginationCursorDirection BeforeOrAfter { get; set; } =
            PaginationCursorDirection.Before;
    }
}
