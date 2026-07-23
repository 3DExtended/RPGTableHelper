import 'dart:async';
import 'dart:convert';

import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/config_sync/config_sync_models.dart';

typedef ConfigSyncWriter = Future<HRResponse<ConfigWriteResult>> Function(
  int? fromRevision,
  String fullConfigJson,
);

typedef ConfigSyncReader = Future<HRResponse<ConfigSnapshot>> Function(
  int? sinceRevision,
);

typedef ConfigSyncApplyFull = void Function(
  String fullConfigJson,
  int revision,
);

typedef ConfigSyncApplyPatch = void Function(
  List<dynamic> patchOperations,
  int revision,
);

/// Drives the "new path" write/catch-up flow for a single campagne or player
/// character config document (sse-04):
///
/// - Local edits are debounced and coalesced: only the most recent desired
///   document is kept, and at most one PUT is ever in flight for this entity.
/// - On `409` (stale `fromRevision`) the coordinator re-fetches the current
///   revision/document, applies the server's view, and retries the write
///   rebased on the new revision.
/// - On an inbound `*ConfigChanged` SSE notify, the coordinator fetches
///   `GET ?sinceRevision=` and applies the returned patch (or full document)
///   via [applyFull]/[applyPatch] so callers can push the result into their
///   Riverpod store.
///
/// This intentionally has no dependency on `IRpgEntityService` or Riverpod:
/// callers wire [write]/[read] to REST calls and [applyFull]/[applyPatch] to
/// their state notifiers, which keeps this class trivially testable.
class ConfigSyncCoordinator {
  ConfigSyncCoordinator({
    required this.write,
    required this.read,
    required this.applyFull,
    required this.applyPatch,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.maxConflictRetriesPerFlush = 5,
  });

  final ConfigSyncWriter write;
  final ConfigSyncReader read;
  final ConfigSyncApplyFull applyFull;
  final ConfigSyncApplyPatch applyPatch;
  final Duration debounceDuration;
  final int maxConflictRetriesPerFlush;

  int? _revision;
  String? _pendingDesiredJson;
  bool _writeInFlight = false;
  Timer? _debounceTimer;
  bool _disposed = false;

  /// Last revision this coordinator knows about (seeded, written, or
  /// caught-up), or `null` before the first hydration.
  int? get revision => _revision;

  /// True while a write is in flight (single-in-flight guarantee).
  bool get isWriteInFlight => _writeInFlight;

  /// True while a local edit is debounced and waiting to be flushed.
  bool get hasPendingLocalEdit => _pendingDesiredJson != null;

  /// Seeds the baseline revision without a network call (e.g. right after
  /// table session hydration already fetched the document by another path).
  void seed({required int revision}) {
    _revision = revision;
  }

  /// Pulls the current full document + revision from the server to seed (or
  /// refresh) the baseline, applying it via [applyFull].
  Future<void> hydrate() async {
    final result = await read(null);
    if (!result.isSuccessful || result.result == null) {
      return;
    }
    final snapshot = result.result!;
    _revision = snapshot.revision;
    if (snapshot.fullConfig != null) {
      applyFull(snapshot.fullConfig!, snapshot.revision);
    }
  }

  /// Call whenever the local (UI-driven) config document changes. Debounces
  /// and coalesces: only the latest [fullConfigJson] survives until flush.
  void notifyLocalEdit(String fullConfigJson) {
    if (_disposed) return;
    _pendingDesiredJson = fullConfigJson;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      unawaited(_flush());
    });
  }

  /// Test/advanced hook: cancels any pending debounce wait and flushes the
  /// latest desired edit (if any) immediately.
  Future<void> flushNow() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    return _flush();
  }

  /// Call when an inbound `*ConfigChanged` SSE notify arrives for this
  /// entity. Fetches a catch-up snapshot and applies it, unless a write is
  /// currently in flight (that write will itself rebase via 409 if stale) or
  /// the notified revision is already known.
  Future<void> onRemoteChanged(int remoteRevision) async {
    if (_disposed || _writeInFlight) {
      return;
    }
    if (_revision != null && remoteRevision <= _revision!) {
      return;
    }
    await _catchUp();
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  Future<void> _flush({int conflictRetryAttempt = 0}) async {
    if (_disposed || _writeInFlight) {
      return;
    }
    if (_pendingDesiredJson == null) {
      return;
    }

    _writeInFlight = true;
    var needsImmediateRetry = false;
    var nextAttempt = conflictRetryAttempt;
    try {
      final desired = _pendingDesiredJson!;
      _pendingDesiredJson = null;

      final result = await write(_revision, desired);
      if (result.statusCode == 409 &&
          conflictRetryAttempt < maxConflictRetriesPerFlush) {
        await _catchUp();
        _pendingDesiredJson = desired;
        needsImmediateRetry = true;
        nextAttempt = conflictRetryAttempt + 1;
      } else if (result.isSuccessful && result.result != null) {
        _revision = result.result!.revision;
      }
    } finally {
      _writeInFlight = false;
    }

    if (needsImmediateRetry || _pendingDesiredJson != null) {
      await _flush(
        conflictRetryAttempt: needsImmediateRetry ? nextAttempt : 0,
      );
    }
  }

  Future<void> _catchUp() async {
    final result = await read(_revision);
    if (!result.isSuccessful || result.result == null) {
      return;
    }

    final snapshot = result.result!;
    if (snapshot.isFull && snapshot.fullConfig != null) {
      _revision = snapshot.revision;
      applyFull(snapshot.fullConfig!, snapshot.revision);
    } else if (snapshot.isPatch && snapshot.patch != null) {
      _revision = snapshot.revision;
      final patchOps = jsonDecode(snapshot.patch!) as List<dynamic>;
      if (patchOps.isNotEmpty) {
        applyPatch(patchOps, snapshot.revision);
      }
    }
  }
}
