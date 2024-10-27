# rpg_table_helper

A new Flutter project.

## TODOs

- [ ] Add Money calculator
- [ ] Add character screens
- [ ] Reconnect creates new ConnectionIds which then are not within the SignalR Groups related to the group.
  - The correct way to fix this is using logins, however for the first working prototype we might get away with adding everyone to only one group without differentiating between dm group and all group.
    - This might be an issue though since the "isDm" flag might be set somewhere else in the client
- [ ] Changable Server IP
- [x] Make a screen for showing and changing the currency for the players
- [x] Players should be able to consume items...
- [x] Send Items based on "search" to clients
  - [x] Enter rolls from players
  - [x] "Roll new Items for Players"
  - [x] "Send items to players"-SignalR-Feature
- [x] Players should be able to add items themselfs
- [x] Safe inventory and player name for players
- [x] Hide items with count = 0
  
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Dev

Update golden tests:

```flutter test --update-goldens```

Build generated code:
```dart run build_runner build```

Update launcher icons:

```flutter pub get && dart run flutter_launcher_icons```
