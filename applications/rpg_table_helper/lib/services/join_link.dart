import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:quest_keeper/helpers/join_code_input_formatter.dart';

/// Links that open the join dialog with the code filled in, e.g. from the QR
/// code of "Spieler einladen": `questkeeper://join?code=699-457`.
///
/// They arrive through Flutter's deep linking (on by default): while the app
/// runs as route information ([JoinLinkObserver]), on an Android cold start
/// as the initial route ([PlatformDispatcher.defaultRouteName]).
const joinLinkScheme = 'questkeeper';

/// The link for [joinCode].
String joinLinkFor(String joinCode) => Uri(
  scheme: joinLinkScheme,
  host: 'join',
  queryParameters: {'code': joinCode},
).toString();

/// The join code of a join link ([location] as the platform passes it), or
/// null for anything else. Takes `questkeeper://join?code=…` and, should a
/// platform pass only path and query, `/join?code=…`.
String? joinCodeFromLink(String location) {
  final uri = Uri.tryParse(location);
  if (uri == null) return null;
  final isJoin =
      (uri.scheme == joinLinkScheme && uri.host == 'join') ||
      (uri.scheme.isEmpty && uri.pathSegments.firstOrNull == 'join');
  if (!isJoin) return null;
  final code = uri.queryParameters['code'] ?? '';
  if (validateJoinCode(code) != null) return null;
  return formatJoinCode(code);
}

/// The code of the last join link, until the home screen opens the join
/// dialog with it.
final pendingJoinLinkCode = ValueNotifier<String?>(null);

/// Takes join links before the [Navigator] would try them as routes. Must be
/// added before the app's [WidgetsApp] registers itself ([listenForJoinLinks]).
class JoinLinkObserver with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final code = joinCodeFromLink(routeInformation.uri.toString());
    if (code == null) return false;
    pendingJoinLinkCode.value = code;
    return true;
  }
}

/// Starts listening for join links; call once in `main` before `runApp`.
JoinLinkObserver listenForJoinLinks({
  WidgetsBinding? binding,
  String? initialRoute,
}) {
  final observer = JoinLinkObserver();
  (binding ?? WidgetsBinding.instance).addObserver(observer);
  final code = joinCodeFromLink(
    initialRoute ?? PlatformDispatcher.instance.defaultRouteName,
  );
  if (code != null) pendingJoinLinkCode.value = code;
  return observer;
}
