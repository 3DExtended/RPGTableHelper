using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RPGTableHelper.DataLayer.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "OpenSignInProviderRegisterRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    ExposedApiKey = table.Column<string>(type: "TEXT", nullable: false),
                    Email = table.Column<string>(type: "TEXT", nullable: false),
                    IdentityProviderId = table.Column<string>(type: "TEXT", nullable: false),
                    SignInProviderRefreshToken = table.Column<string>(type: "TEXT", nullable: true),
                    SignInProviderUsed = table.Column<int>(type: "INTEGER", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OpenSignInProviderRegisterRequests", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    SignInProviderId = table.Column<string>(type: "TEXT", nullable: true),
                    SignInProvider = table.Column<int>(type: "INTEGER", nullable: true),
                    Username = table.Column<string>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Campagnes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    RpgConfiguration = table.Column<string>(type: "TEXT", nullable: true),
                    CampagneName = table.Column<string>(type: "TEXT", nullable: false),
                    JoinCode = table.Column<string>(type: "TEXT", nullable: false),
                    DmUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Campagnes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Campagnes_Users_DmUserId",
                        column: x => x.DmUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "EncryptionChallenges",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    PasswordPrefix = table.Column<string>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: true),
                    RndInt = table.Column<int>(type: "INTEGER", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EncryptionChallenges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EncryptionChallenges_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PlayerCharacters",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    RpgCharacterConfiguration = table.Column<string>(type: "TEXT", nullable: true),
                    CharacterName = table.Column<string>(type: "TEXT", nullable: false),
                    PlayerUserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CampagneId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayerCharacters", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlayerCharacters_Campagnes_CampagneId",
                        column: x => x.CampagneId,
                        principalTable: "Campagnes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_PlayerCharacters_Users_PlayerUserId",
                        column: x => x.PlayerUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserCredentials",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Deleted = table.Column<bool>(type: "INTEGER", nullable: false),
                    Email = table.Column<string>(type: "TEXT", nullable: true),
                    EmailVerified = table.Column<bool>(type: "INTEGER", nullable: true),
                    EncryptionChallengeId = table.Column<Guid>(type: "TEXT", nullable: true),
                    HashedPassword = table.Column<string>(type: "TEXT", nullable: true),
                    PasswordResetToken = table.Column<string>(type: "TEXT", nullable: true),
                    PasswordResetTokenExpireDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: true),
                    RefreshToken = table.Column<string>(type: "TEXT", nullable: true),
                    SignInProvider = table.Column<bool>(type: "INTEGER", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CreationDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    LastModifiedAt = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserCredentials", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserCredentials_EncryptionChallenges_EncryptionChallengeId",
                        column: x => x.EncryptionChallengeId,
                        principalTable: "EncryptionChallenges",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserCredentials_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Campagnes_DmUserId",
                table: "Campagnes",
                column: "DmUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Campagnes_JoinCode",
                table: "Campagnes",
                column: "JoinCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EncryptionChallenges_UserId",
                table: "EncryptionChallenges",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PlayerCharacters_CampagneId",
                table: "PlayerCharacters",
                column: "CampagneId");

            migrationBuilder.CreateIndex(
                name: "IX_PlayerCharacters_PlayerUserId",
                table: "PlayerCharacters",
                column: "PlayerUserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserCredentials_EncryptionChallengeId",
                table: "UserCredentials",
                column: "EncryptionChallengeId");

            migrationBuilder.CreateIndex(
                name: "IX_UserCredentials_UserId",
                table: "UserCredentials",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OpenSignInProviderRegisterRequests");

            migrationBuilder.DropTable(
                name: "PlayerCharacters");

            migrationBuilder.DropTable(
                name: "UserCredentials");

            migrationBuilder.DropTable(
                name: "Campagnes");

            migrationBuilder.DropTable(
                name: "EncryptionChallenges");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
