using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class FixImageMetaData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_imageMetaDatas_Users_CreatedForCampagneId",
                table: "imageMetaDatas");

            migrationBuilder.AddForeignKey(
                name: "FK_imageMetaDatas_Campagnes_CreatedForCampagneId",
                table: "imageMetaDatas",
                column: "CreatedForCampagneId",
                principalTable: "Campagnes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_imageMetaDatas_Campagnes_CreatedForCampagneId",
                table: "imageMetaDatas");

            migrationBuilder.AddForeignKey(
                name: "FK_imageMetaDatas_Users_CreatedForCampagneId",
                table: "imageMetaDatas",
                column: "CreatedForCampagneId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
