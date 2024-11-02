using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddImageMetaData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "imageMetaDatas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedForCampagneId = table.Column<Guid>(type: "TEXT", nullable: false),
                    LocallyStored = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatorId = table.Column<Guid>(type: "TEXT", nullable: false),
                    ImageType = table.Column<int>(type: "INTEGER", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_imageMetaDatas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_imageMetaDatas_Users_CreatedForCampagneId",
                        column: x => x.CreatedForCampagneId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_imageMetaDatas_Users_CreatorId",
                        column: x => x.CreatorId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_imageMetaDatas_CreatedForCampagneId",
                table: "imageMetaDatas",
                column: "CreatedForCampagneId");

            migrationBuilder.CreateIndex(
                name: "IX_imageMetaDatas_CreatorId",
                table: "imageMetaDatas",
                column: "CreatorId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "imageMetaDatas");
        }
    }
}
