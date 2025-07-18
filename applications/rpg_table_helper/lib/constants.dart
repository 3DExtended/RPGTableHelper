import 'dart:io';

const iconSizeInlineButtons = 16.0;

const pingInterval = Duration(seconds: 3);

bool get isInTestEnvironment =>
    Platform.environment.containsKey('FLUTTER_TEST');

// -----------

const paddingBeforeAndAfterNavbarButtons = 5.0;

const outerPadding = 20.0;

const sharedPrefsKeyRpgConfigJson = "rpgconfig";
const sharedPrefsKeyRpgCharacterConfigJson = "rpgcharacterconfig";

// The location of the SignalR Server.
// NOTE: Make sure to include the trailing slash.
// const apiBaseUrl = kDebugMode
//     ? "http://localhost:5012/"
//     : "https://questkeeper-prod.peter-esser.de/";
const apiBaseUrl = "https://questkeeper-prod.peter-esser.de/";

const serverUrl = "${apiBaseUrl}Chat";

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
