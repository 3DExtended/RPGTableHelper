import 'dart:io';

const iconSizeInlineButtons = 16.0;

/// How often the DM app sends SignalR pings and runs presence checks.
const pingInterval = Duration(seconds: 5);

/// Player UI: warn if no DM ping received for this long (less aggressive than one missed tick).
const playerDisconnectedFromDmAfter = Duration(seconds: 12);

/// DM list: consider a player's `lastPing` stale only after this age before counting toward removal.
const dmPlayerPingStaleThreshold = Duration(seconds: 15);

/// DM list: require this many consecutive periodic checks with a stale ping before removing the player.
const dmConsecutiveStaleChecksBeforeRemove = 3;

/// DM: delay removing a player after SignalR `clientDisconnected` so brief reconnects do not flash offline.
const clientDisconnectedDebounce = Duration(seconds: 4);

/// Max pending critical hub invokes when offline (oldest dropped when exceeded).
const hubInvokeQueueMaxItems = 20;

/// Drain queued invokes on this interval while in session and queue non-empty.
const hubInvokeQueueDrainPeriodicInterval = Duration(seconds: 30);

bool get isInTestEnvironment =>
    Platform.environment.containsKey('FLUTTER_TEST');

// -----------

const paddingBeforeAndAfterNavbarButtons = 5.0;

const outerPadding = 20.0;

const sharedPrefsKeyRpgConfigJson = "rpgconfig";
const sharedPrefsKeyRpgCharacterConfigJson = "rpgcharacterconfig";

// The location of the REST API and SignalR server.
// NOTE: Include the trailing slash. Override for local E2E:
// `--dart-define=API_BASE_URL=http://127.0.0.1:5012/`
String get apiBaseUrl {
  const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromDefine.isNotEmpty) {
    var u = fromDefine;
    if (!u.endsWith('/')) {
      u = '$u/';
    }
    return u;
  }
  return 'https://questkeeper-prod.peter-esser.de/';
}

String get serverUrl => '${apiBaseUrl}Chat';

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
