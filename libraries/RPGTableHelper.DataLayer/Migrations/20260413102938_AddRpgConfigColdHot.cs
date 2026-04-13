using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddRpgConfigColdHot : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "RpgConfigurationCold",
                table: "Campagnes",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RpgConfigurationHot",
                table: "Campagnes",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RpgConfigurationSchemaVersion",
                table: "Campagnes",
                type: "INTEGER",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RpgConfigurationCold",
                table: "Campagnes");

            migrationBuilder.DropColumn(
                name: "RpgConfigurationHot",
                table: "Campagnes");

            migrationBuilder.DropColumn(
                name: "RpgConfigurationSchemaVersion",
                table: "Campagnes");
        }
    }
}
