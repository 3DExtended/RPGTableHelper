# rpg_table_helper

A new Flutter project.

## TODOs

- [ ] Add character screens
- [ ] You can not see which items you are missing for crafting a recipe...
- [ ] Add Money calculator
- [ ] Add forgot password screen
- [ ] JoinCampagneRequests
  - [ ] The dm is currently not notified through signalr that a player has opened a new join request. Theoretically, only the client part should be needed as i have implemented the backend part already
  - [ ] Currently, after a player has requested a join request to a campagne they are not notified after they have been accepted or denied...
- [x] add a popup when the player has received items from the dm through the ```grantPlayerItems``` method
- [x] Add usage of jwt for signalr connection
- [x] add screen for selecting Campagnes (as DM) or a character
- [x] Add screen for joining a session
- [x] Add complete SSO screen
- [x] Reconnect creates new ConnectionIds which then are not within the SignalR Groups related to the group.
  - The correct way to fix this is using logins, however for the first working prototype we might get away with adding everyone to only one group without differentiating between dm group and all group.
    - This might be an issue though since the "isDm" flag might be set somewhere else in the client
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
