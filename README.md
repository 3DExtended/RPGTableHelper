# RPG Table Helper

## 🎲 Overview

**RPG Table Helper** is a Flutter-powered application with an ASP.NET backend designed to assist Dungeon Masters (DMs) and players in managing their tabletop RPG campaigns, characters, and notes. This tool is tailored for games like *Dungeons & Dragons*, *Daggerheart*, and similar physical RPGs to streamline gameplay, remove the need for paper, and provide real-time synchronization. This app focuses on tablets but does work on smartphones as well.

---

## ✨ Key Features

- **Create and Manage Multiple Campaigns**: Easily organize and handle different RPG campaigns in one app.
- **Share Notes with Players**: Keep all players on the same page by sharing story notes, quests, and world-building details.
- **Customizable Character Sheets**: Tailor character attributes, stats, and abilities to fit your gameplay style.
- **Digital Inventory Management**: Streamline item tracking and management.
- **Eliminate Paper at the Table**: Say goodbye to printed materials and hand-written notes.
- **Real-Time Updates Across Devices**: Changes to character states or stats sync across all players and DMs in real time.
- **Play Remotely with Friends**: Designed for remote play, allowing groups to connect seamlessly and role-play from any location.
- **AI-Powered Visualizations**: Use AI to generate visual representations of items and characters.
- **Grant Items with Ease**: DMs can award items to players instantly with just one button press (e.g. for exploration rewards).
- **Real-Time Party Overview**: DMs can view the full party’s stats and health to make strategic combat adjustments.

---

## 🚀 Getting Started (User Notes)

### Account Requirement

To start using RPG Table Helper, all users (players and DMs) must create an account. Options include:

- **Google Sign-In**
- **Apple Sign-In**
- **Email & Password Registration**

Once registered, DMs can create a new campaign, and players can create their characters. A campaign setup wizard guides DMs through configuring:

- The name of the campaign
- The world’s currency system
- Default character statistics to be populated by players joining the campaign
- Adding initial items to the world

### 📸 Screenshots

Below are visual examples of the app’s interface:

#### Logo

<img src="/applications/rpg_table_helper/assets/icons/icon.png" width="256">

#### DM Campaign Management Screen

<img src="/applications/rpg_table_helper/test/goldens/dmpagescreensdmcampagnemanagmentscreen/1 - dmpagescreensdmcampagnemanagmentscreen (Language de, default).ipad 6th gen landscape.png" width="768">

#### DM Inititive Screen

<img src="/applications/rpg_table_helper/test/goldens/dmpagescreensdminitiativescreen/1%20-%20dmpagescreensdminitiativescreen%20(Language%20de,%20default).ipad%20pro%2011inch%204th%20gen.png" width="768">

#### Player Character Stats Screen

<img src="/applications/rpg_table_helper/test/goldens/playerpagescreens1-playerstatsscreen/1 - playerpagescreens1-playerstatsscreen (Language de, default).ipad pro 11inch 4th gen.png" width="768">

#### Players Inventory Screen

<img src="/applications/rpg_table_helper/test/goldens/playerpagescreens6-playerinventoryscreen/1 - playerpagescreens6-playerinventoryscreen (Language de, default).ipad pro 12-9 landscape.png" width="768">

#### Players Balance Calculator

<img src="/applications/rpg_table_helper/test/goldens/playerpagescreens5-playermoneyscreen/1 - playerpagescreens5-playermoneyscreen (Language en, default).ipad 6th gen landscape.png" width="768">

---

## 🧩 Features Roadmap

Here are some features we plan to implement in the near future:

- **"Druid" Characters:** A modular character system allowing players to mix and select traits, features, and abilities into a single unified character. This system is similar to shapeshifters or hybrid forms, allowing versatile customization.
- **Improved Real-Time Performance:** Optimizing SignalR communication to ensure faster and seamless updates when sending real-time updates about characters.
- **Decentralized Hosting with Azure:** Investigating decentralized hosting with Azure to improve scalability, reliability, and provide hosting options for DMs or campaigns.
- **Localization:** I am planning on localizing this app at least for english and german. Help is very much appreciated for other languages!

## 💬 Contributing

We welcome all feedback and contributions to improve RPG Table Helper. If you find a bug, have feature suggestions, or would like to contribute:

- **Report issues or ideas via GitHub Issues.**

Your feedback and help are always appreciated! 💖

---

## 🚀 Getting Started (Dev Notes)

### Prerequisites

To run the app, ensure you have the following installed:

- **.NET 9 SDK**: Required for backend.
- **Flutter SDK**: Required for frontend development.

### Installation Instructions

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/3DExtended/RPGTableHelper.git
   ```

2. **Install Dependencies:**
   - For backend dependencies:

     ```bash
     dotnet restore
     dotnet build .
     ```

   - For frontend dependencies:

     ```bash
     cd applications/rpg_table_helper
     flutter pub get
     ```

3. **Start the Backend Server:**

   ```bash
   cd applications/RPGTableHelper.WebApi
   dotnet run .
   ```

4. **Start the Frontend:**

    ```bash
    cd applications/rpg_table_helper
    flutter run
    ```

### Other Useful Commands

#### Add efcore migration

Run this in the root folder:
```dotnet ef migrations add <Name> -c RpgDbContext -s applications/RPGTableHelper.WebApi -p libraries/RPGTableHelper.DataLayer```

```dotnet ef database update -c RpgDbContext -s applications/RPGTableHelper.WebApi -p libraries/RPGTableHelper.DataLayer```

#### Update C# dependencies

```dotnet outdated -u:Prompt -r```

**NOTE:** To find, why a given dependency is in your repository search all ```obj/project.assets``` files.

#### Code Coverage

```sh
dotnet test --collect:"XPlat Code Coverage" --results-directory cobertura
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"." -reporttypes:"cobertura"
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coveragereport" -reporttypes:Html
COVERAGE_VALUE=$(grep -oPm 1 'line-rate="\K([0-9.]+)' "./Cobertura.xml")
COVERAGE=$(echo "scale=2; $COVERAGE_VALUE * 100" | bc)
'echo "TOTAL_COVERAGE=$COVERAGE%"'
```

## 🛠️ Technologies Used

- **Frontend:** Flutter
- **Backend:** ASP.NET
- **Real-Time Communication:** SignalR

## 📬 Contact

For feedback, questions, or collaboration, please use the [GitHub Issues](https://github.com/3DExtended/RPGTableHelper/issues).

Thank you for supporting RPG Table Helper! Happy role-playing! 🎲

## 📜 License

This project is licensed under the terms specified in the `LICENSE` file.

## 🤝 Acknowledgments

We would like to acknowledge the use of icons from:

- [FontAwesome](https://fontawesome.com)
- [SVGRepo](https://www.svgrepo.com)

Thank you for these amazing resources!
