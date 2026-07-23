import 'dart:async';
import 'dart:convert';

import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

/// Listens on the shared [EventsClient] stream for the membership-scoped
/// `noteAccessChanged` SSE notify (sse-07), emitted whenever a note document
/// or block is created/updated/deleted, or a block's `permittedUsers` change
/// such that a user gains, loses, or keeps access.
///
/// Like [JoinRequestNotificationController], this is not session-gated: a
/// user must learn about revoked/granted lore access even without an active
/// `SessionEnter` for the campagne. Callers should start this once the lore
/// screen (or app shell) is active and stop it when no longer needed.
class NoteAccessNotificationController {
  NoteAccessNotificationController({
    required this.eventsClient,
    required this.onNoteAccessChanged,
  });

  final EventsClient eventsClient;
  final void Function(NoteAccessChangedEvent event) onNoteAccessChanged;

  StreamSubscription<SseEvent>? _subscription;

  void start() {
    _subscription ??= eventsClient.events.listen(_onSseEvent);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onSseEvent(SseEvent event) {
    if (event.type != 'noteAccessChanged') {
      return;
    }

    final parsed = _tryParse(event.data);
    if (parsed != null) {
      onNoteAccessChanged(parsed);
    }
  }

  NoteAccessChangedEvent? _tryParse(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final campagneId = json['campagneId'] as String?;
      final documentId = json['documentId'] as String?;
      final blockId = json['blockId'] as String?;
      final changeKindRaw = json['changeKind'] as String?;
      if (campagneId == null || documentId == null || changeKindRaw == null) {
        return null;
      }

      final changeKind = _parseChangeKind(changeKindRaw);
      if (changeKind == null) {
        return null;
      }

      return NoteAccessChangedEvent(
        campagneId: campagneId,
        documentId: documentId,
        blockId: blockId,
        changeKind: changeKind,
      );
    } catch (_) {
      return null;
    }
  }

  NoteAccessChangeKind? _parseChangeKind(String raw) {
    switch (raw) {
      case 'granted':
        return NoteAccessChangeKind.granted;
      case 'revoked':
        return NoteAccessChangeKind.revoked;
      case 'updated':
        return NoteAccessChangeKind.updated;
      default:
        return null;
    }
  }
}

/// Kind of access change carried by a `noteAccessChanged` SSE payload.
enum NoteAccessChangeKind {
  /// The recipient gained access to the document/block (or it was just
  /// created while shared with them).
  granted,

  /// The recipient lost access to the document/block (or it, or its parent
  /// document, was deleted).
  revoked,

  /// The recipient still has access, but the content changed.
  updated,
}

/// Parsed `noteAccessChanged` SSE payload: ids plus the change kind only -
/// no note bodies are ever sent inline.
class NoteAccessChangedEvent {
  const NoteAccessChangedEvent({
    required this.campagneId,
    required this.documentId,
    required this.blockId,
    required this.changeKind,
  });

  final String campagneId;
  final String documentId;

  /// Null for document-level changes (e.g. document deleted or its title
  /// updated); set for block-level changes.
  final String? blockId;
  final NoteAccessChangeKind changeKind;
}
