using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddMarkdownTextToImageBlocks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TextBlockEntity_MarkdownText",
                table: "NoteBlocks",
                type: "TEXT",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TextBlockEntity_MarkdownText",
                table: "NoteBlocks");
        }
    }
}
