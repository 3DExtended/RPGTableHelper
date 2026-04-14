using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddRpgConfigurationMergedRevision : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RpgConfigurationMergedRevision",
                table: "Campagnes",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RpgConfigurationMergedRevision",
                table: "Campagnes");
        }
    }
}
