import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

/// Hint over every screen while the live-update stream cannot reach the
/// server, so nobody at the table keeps waiting for updates that will not
/// come. Short drops stay quiet: only [EventsConnectionStatus.unreachable]
/// shows it. It never takes taps, so the screen below stays usable.
///
/// Place it as a child of a [Stack] that covers the screen.
class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key, required this.status});

  final ValueListenable<EventsConnectionStatus> status;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 0,
      child: IgnorePointer(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Center(
              child: ValueListenableBuilder<EventsConnectionStatus>(
                valueListenable: status,
                builder: (context, value, _) =>
                    value == EventsConnectionStatus.unreachable
                    ? const _Pill()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF0312D28),
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                S.of(context).connectionLostReconnecting,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
