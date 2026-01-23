# Project Overview: RPG Table Helper

## 1. Introduction

**RPG Table Helper** is a tablet-focused tool for Dungeon Masters and players to manage tabletop RPG campaigns (D&D, Daggerheart, etc.).

- **Goal**: Eliminate paper, provide real-time sync, manage inventories/stats.
- **Platforms**: Tablet (primary), Mobile.

## 2. Technology Stack

### Backend (`applications/RPGTableHelper.WebApi`)

- **Framework**: .NET 9 (ASP.NET Core).
- **Communication**: REST API (Controllers) & SignalR (Real-time).
- **Database**: SQLite (Dev/Docker Containers), Entity Framework Core (EF Core) 9.0.
- **Patterns**:
  - **CQRS**: Uses `Prodot.Patterns.Cqrs` library.
  - **Dependency Injection**: Heavy use of DI for Services, Repositories, and CQRS handlers.
  - **Strongly Typed IDs**: Entities use custom struct IDs (e.g., `UserIdentifier`, `CampagneIdentifier`) to prevent mixing up GUIDs.
- **External Services**:
  - **SendGrid**: Email services.
  - **OpenAI**: AI generation features.
  - **Apple Sign-In**: Auth provider.

### Frontend (`applications/rpg_table_helper`)

- **Framework**: Flutter (v3.5.0+).
- **Language**: Dart.
- **State Management**: **Riverpod** (v2.5.1) with Code Generation.
- **Networking**:
  - **Chopper**: For REST API generation.
  - **SignalR Client**: For real-time updates.
- **Localization**: `flutter_localizations`, `intl` (English/German).
- **Design**: Material 3, Custom Theme Provider (`CustomThemeProvider`), `Ruwudu` Font.

## 3. Project Structure

The solution follows a clean separation of concerns:

- `applications/`: Executable projects.
  - `RPGTableHelper.WebApi`: Backend server.
  - `rpg_table_helper`: Flutter app.
- `libraries/`: Shared logic and infrastructure.
  - `RPGTableHelper.BusinessLayer`: Domain logic, command/query handlers.
  - `RPGTableHelper.DataLayer`: EF Core context, migrations, entities.
  - `RPGTableHelper.Shared`: DTOs, Enums, Shared Models (used by both API and Clients if C# client exists, otherwise acts as source of truth).
- `tests/`: Test projects mirroring logical layers.
  - `RPGTableHelper.Api.Tests`: Integration/Unit tests for API layer (Mapping, Controllers).
  - `RPGTableHelper.DataLayer.Tests`, etc.

## 4. Key Design Patterns

### Backend

- **CQRS Pipeline**: Queries and Commands are handled via `IQueryProcessor` and mediators. Handlers are registered in `Startup.cs` via `AddProdotPatternsCqrs`.
- **EF Core Configuration**:
  - `RpgDbContext` handles automatic timestamping (`CreationDate`, `LastModifiedAt`) via `ChangeTracker`.
  - Usage of `Discriminator` for polymorphic types (e.g., `NoteBlockEntityBase` -> `TextBlockEntity`, `ImageBlockEntity`).
- **AutoMapper**: Used extensively to map Entities <-> DTOs.
- **Polymorphism**: `NoteBlocks` (Text/Image) handled via EF Core discriminators and mapped to corresponding DTOs.

### Frontend

- **Riverpod Providers**: Used for everything from simple state to API clients and services.
- **Feature-based folders**: `screens/`, `components/`, `models/`, `services/`.
- **Generated Code**: Heavy reliance on `json_serializable`, `chopper_generator`, `freezed`/`copy_with` for immutability and serialization.

## 5. Testing Strategy

- **Framework**: **xUnit**.
- **Assertions**: **FluentAssertions**.
- **Mocking**: **NSubstitute**.
- **Integration**: `Microsoft.AspNetCore.Mvc.Testing` available for full API tests.
- **Coverage**: Emphasis on Mapping logic (`ApiDtoMapperProfileTests`) and Business Logic.
- **Required Tests**: All new queryhandlers must have unit tests!

## 6. Development Workflow (Cheatsheet)

- **Backend Run**: `cd applications/RPGTableHelper.WebApi && dotnet run`
- **Frontend Run**: `cd applications/rpg_table_helper && flutter run`
- **Migrations**:
  - Add: `dotnet ef migrations add <Name> -c RpgDbContext -s applications/RPGTableHelper.WebApi -p libraries/RPGTableHelper.DataLayer`
  - Update: `dotnet ef database update ...` (or rely on auto-migration in `Startup.cs`).

## 7. Important Constraints & Rules

- **Localization**: All user-facing strings MUST be localized (English & German).
- **Strong Typing**: Respect the strongly typed ID patterns in the backend; do not treat IDs as raw GUIDs if wrappers exist.
- **Secrets**: Use `secrets.json` for local dev; environment variables in Prod.
