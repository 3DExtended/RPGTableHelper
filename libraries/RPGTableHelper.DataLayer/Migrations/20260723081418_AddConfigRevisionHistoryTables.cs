using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddConfigRevisionHistoryTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CampagneRpgConfigHistories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    CampagneId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Revision = table.Column<int>(type: "INTEGER", nullable: false),
                    ConfigJson = table.Column<string>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CampagneRpgConfigHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CampagneRpgConfigHistories_Campagnes_CampagneId",
                        column: x => x.CampagneId,
                        principalTable: "Campagnes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PlayerCharacterRpgConfigHistories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    PlayerCharacterId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Revision = table.Column<int>(type: "INTEGER", nullable: false),
                    ConfigJson = table.Column<string>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayerCharacterRpgConfigHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlayerCharacterRpgConfigHistories_PlayerCharacters_PlayerCharacterId",
                        column: x => x.PlayerCharacterId,
                        principalTable: "PlayerCharacters",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CampagneRpgConfigHistories_CampagneId_Revision",
                table: "CampagneRpgConfigHistories",
                columns: new[] { "CampagneId", "Revision" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PlayerCharacterRpgConfigHistories_PlayerCharacterId_Revision",
                table: "PlayerCharacterRpgConfigHistories",
                columns: new[] { "PlayerCharacterId", "Revision" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CampagneRpgConfigHistories");

            migrationBuilder.DropTable(
                name: "PlayerCharacterRpgConfigHistories");
        }
    }
}
