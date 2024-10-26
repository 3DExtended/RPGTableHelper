using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddCampagneJoinRequests : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CampagneJoinRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PlayerId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CampagneId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CampagneJoinRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CampagneJoinRequests_Campagnes_CampagneId",
                        column: x => x.CampagneId,
                        principalTable: "Campagnes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CampagneJoinRequests_PlayerCharacters_PlayerId",
                        column: x => x.PlayerId,
                        principalTable: "PlayerCharacters",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CampagneJoinRequests_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CampagneJoinRequests_CampagneId_PlayerId",
                table: "CampagneJoinRequests",
                columns: new[] { "CampagneId", "PlayerId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CampagneJoinRequests_CampagneId_UserId",
                table: "CampagneJoinRequests",
                columns: new[] { "CampagneId", "UserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CampagneJoinRequests_PlayerId",
                table: "CampagneJoinRequests",
                column: "PlayerId");

            migrationBuilder.CreateIndex(
                name: "IX_CampagneJoinRequests_UserId",
                table: "CampagneJoinRequests",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CampagneJoinRequests");
        }
    }
}
