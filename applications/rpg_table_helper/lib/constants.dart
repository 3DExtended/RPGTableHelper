import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const darkColor = Color(0xff312D28);
const middleBgColor = Color(0xffE4D5C5);
const bgColor = Color(0xffFDF0E3);
const textColor = Color(0xffffffff);
const accentColor = Color(0xffF96F3D);

const darkTextColor = darkColor;
const iconSizeInlineButtons = 16.0;

// -----------

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
const apiBaseUrl =
    kDebugMode ? "http://localhost:5012/" : "https://rpghelper.peter-esser.de/";
const serverUrl = "${apiBaseUrl}Chat";

const whiteBgTint = Color.fromARGB(33, 210, 191, 221);

const rpgtablehelperPublicCertificate = '''-----BEGIN PUBLIC KEY-----
MIICLjANBgkqhkiG9w0BAQEFAAOCAhsAMIICFgKCAg0LBlhtjPsdRKW8xNSSfqAr
WAnoODMM3mSgpPDLz9WdCDm5Ms+MvqWm635c+kvpgKNI2OMMuwtx3bOlT7l8th/0
d6D6KAEzQmxuJ5uREJSqCtxsC1GxTomyql3Z93G740vdfbFX069et08YVMlvHjgv
l53YDeL2zSGqiY79mwpdI/PJDY3jp466vXqlSH2f5nIvsluhn1a3XayXsAMCNeJB
9DTqJOrekOBI+u52Q/kF38lJzmtW05V6sFYyQ8i7Kc7W4t4h3M3J+HiDX+RkMQ7z
DANrK4sQ9dOagJp31Ku8Apg1ShYFUBIcsqzP2B0WdJTCBAH1yhc/Nutqfrboj7aZ
KP8K7QqeGQdNc1VmxbbJFPZZfwe7TZFqxPmBW9Vs+Rsbv+N2ocO8klGJkmOElezi
cVneWP5CCbotUP7WbvlrjdJ71iZmUXEdhzf3hxLcyrSUSpZ5r8I4Xv607CoeUKXi
IHAuRQae2fZ2H0/cAwHttkfYYT2NG6xo4BUqCxo9iWHHCQLM9CXDY/3LdtPsu0Xx
nhKgYxlt1JHoGiN+8+eeNtaBQ3xnuiOLsRLrXZBq4TaO7wzoQb5b5PaXRazByc0A
TvH+/xh46EkwvIUdnslgnU8lpba/F0L9F+kEzZxfn9YyU4/4Ti97u0MOf1A2fN/c
rHwxP/+EDvciyf3gp4Sz/Qp1uiSkict9RxfTG5cCAwEAAQ==
-----END PUBLIC KEY-----''';
