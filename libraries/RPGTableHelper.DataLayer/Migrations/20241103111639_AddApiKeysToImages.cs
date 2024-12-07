using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddApiKeysToImages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ApiKey",
                table: "imageMetaDatas",
                type: "TEXT",
                nullable: false,
                defaultValue: "60ee13de-a7ae-4eb8-a3f2-2e779d59a184e16c6849-f863-463d-b927-daa856875cd1555b07e0-6335-42fd-83c6-6daa8c811507"
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(name: "ApiKey", table: "imageMetaDatas");
        }
    }
}
