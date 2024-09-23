import 'package:flutter/material.dart';

const borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff9FA3A4),
      Color(0xff2F333E),
      Color.fromARGB(255, 89, 115, 144),
    ]);

const navbarBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff2A2E37),
      Color(0xff272B36),
      Color(0xff2A374A),
    ]);
const secondaryNavbarColor = Color(0xff3E4148);

const paddingBeforeAndAfterNavbarButtons = 5.0;

const outerPadding = 20.0;

const sharedPrefsKeyRpgConfigJson = "rpgconfig";
const sharedPrefsKeyRpgCharacterConfigJson = "rpgcharacterconfig";

// The location of the SignalR Server.
const serverUrl = "http://192.168.178.106:5012/Chat";

const whiteBgTint = Color.fromARGB(33, 210, 191, 221);
