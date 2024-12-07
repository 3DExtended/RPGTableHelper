using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class AddNoteDocuments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CampagneDocuments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    GroupName = table.Column<string>(type: "TEXT", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    Title = table.Column<string>(type: "TEXT", nullable: false),
                    CreatingUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreatedForCampagneId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CampagneDocuments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CampagneDocuments_Campagnes_CreatedForCampagneId",
                        column: x => x.CreatedForCampagneId,
                        principalTable: "Campagnes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CampagneDocuments_Users_CreatingUserId",
                        column: x => x.CreatingUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "NoteBlocks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    NoteDocumentId = table.Column<Guid>(type: "TEXT", nullable: false),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatingUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Visibility = table.Column<int>(type: "INTEGER", nullable: false),
                    block_type = table.Column<int>(type: "INTEGER", nullable: false),
                    ImageMetaDataId = table.Column<Guid>(type: "TEXT", nullable: true),
                    PublicImageUrl = table.Column<string>(type: "TEXT", nullable: true),
                    MarkdownText = table.Column<string>(type: "TEXT", nullable: true),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NoteBlocks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_NoteBlocks_CampagneDocuments_NoteDocumentId",
                        column: x => x.NoteDocumentId,
                        principalTable: "CampagneDocuments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_NoteBlocks_Users_CreatingUserId",
                        column: x => x.CreatingUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_NoteBlocks_imageMetaDatas_ImageMetaDataId",
                        column: x => x.ImageMetaDataId,
                        principalTable: "imageMetaDatas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PermittedUsersToNotesBlocks",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    IsDeleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreationDate = table.Column<DateTime>(type: "TEXT", nullable: false),
                    PermittedUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    NotesBlockId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PermittedUsersToNotesBlocks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PermittedUsersToNotesBlocks_NoteBlocks_NotesBlockId",
                        column: x => x.NotesBlockId,
                        principalTable: "NoteBlocks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PermittedUsersToNotesBlocks_Users_PermittedUserId",
                        column: x => x.PermittedUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CampagneDocuments_CreatedForCampagneId",
                table: "CampagneDocuments",
                column: "CreatedForCampagneId");

            migrationBuilder.CreateIndex(
                name: "IX_CampagneDocuments_CreatingUserId",
                table: "CampagneDocuments",
                column: "CreatingUserId");

            migrationBuilder.CreateIndex(
                name: "IX_NoteBlocks_CreatingUserId",
                table: "NoteBlocks",
                column: "CreatingUserId");

            migrationBuilder.CreateIndex(
                name: "IX_NoteBlocks_ImageMetaDataId",
                table: "NoteBlocks",
                column: "ImageMetaDataId");

            migrationBuilder.CreateIndex(
                name: "IX_NoteBlocks_NoteDocumentId",
                table: "NoteBlocks",
                column: "NoteDocumentId");

            migrationBuilder.CreateIndex(
                name: "IX_PermittedUsersToNotesBlocks_NotesBlockId",
                table: "PermittedUsersToNotesBlocks",
                column: "NotesBlockId");

            migrationBuilder.CreateIndex(
                name: "IX_PermittedUsersToNotesBlocks_PermittedUserId",
                table: "PermittedUsersToNotesBlocks",
                column: "PermittedUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PermittedUsersToNotesBlocks");

            migrationBuilder.DropTable(
                name: "NoteBlocks");

            migrationBuilder.DropTable(
                name: "CampagneDocuments");
        }
    }
}
