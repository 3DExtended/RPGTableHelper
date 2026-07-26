import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Active debug session id (matches Cursor debug session when used from IDE).
const agentDebugSessionId = '9eb1db';

const _logFileName = 'agent_debug.ndjson';
const _maxLogFileBytes = 512 * 1024;
const _workspaceDebugLogPath =
    '/Users/peteresser/Developer/projects/archive/rpgTableHelper/.cursor/debug-9eb1db.log';
const _debugIngestUrl =
    'http://127.0.0.1:7464/ingest/582d64c1-b502-4cc5-9e27-7aeb8557927c';

String? _resolvedLogPath;
Completer<String>? _pathCompleter;
Future<void> _appendChain = Future.value();

/// NDJSON log file in app documents (works on device, TestFlight, and simulator).
Future<String> resolveAgentDebugLogPath() async {
  if (_resolvedLogPath != null) {
    return _resolvedLogPath!;
  }
  final existing = _pathCompleter;
  if (existing != null) {
    return existing.future;
  }
  final completer = Completer<String>();
  _pathCompleter = completer;
  try {
    final dir = await getApplicationDocumentsDirectory();
    _resolvedLogPath = '${dir.path}/$_logFileName';
    completer.complete(_resolvedLogPath!);
  } catch (e, st) {
    completer.completeError(e, st);
    _pathCompleter = null;
  }
  return completer.future;
}

void agentDebugLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
  String? hypothesisId,
  String runId = 'pre-fix',
}) {
  _appendChain = _appendChain.then((_) => _appendAgentDebugLog(
        location: location,
        message: message,
        data: data,
        hypothesisId: hypothesisId,
        runId: runId,
      ));
}

Future<void> _appendAgentDebugLog({
  required String location,
  required String message,
  required Map<String, dynamic> data,
  String? hypothesisId,
  required String runId,
}) async {
  // #region agent log
  try {
    final payload = <String, dynamic>{
      'sessionId': agentDebugSessionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'data': data,
      'runId': runId,
      if (hypothesisId != null) 'hypothesisId': hypothesisId,
    };
    final line = '${jsonEncode(payload)}\n';

    final path = await resolveAgentDebugLogPath();
    final file = File(path);
    await file.writeAsString(line, mode: FileMode.append, flush: true);
    await _trimLogFileIfNeeded(file);

    try {
      await File(_workspaceDebugLogPath)
          .writeAsString(line, mode: FileMode.append, flush: true);
    } catch (_) {}

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 400);
      final request = await client.postUrl(Uri.parse(_debugIngestUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('X-Debug-Session-Id', agentDebugSessionId);
      request.add(utf8.encode(jsonEncode(payload)));
      await request.close().timeout(const Duration(milliseconds: 400));
      client.close(force: true);
    } catch (_) {}
  } catch (_) {}
  // #endregion
}

Future<void> _trimLogFileIfNeeded(File file) async {
  if (!await file.exists()) {
    return;
  }
  final length = await file.length();
  if (length <= _maxLogFileBytes) {
    return;
  }
  final content = await file.readAsString();
  final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
  while (lines.isNotEmpty) {
    final candidate = '${lines.join('\n')}\n';
    if (candidate.length <= _maxLogFileBytes) {
      await file.writeAsString(candidate, flush: true);
      return;
    }
    lines.removeAt(0);
  }
  await file.writeAsString('', flush: true);
}

Future<List<Map<String, dynamic>>> readAgentDebugLogEntries() async {
  try {
    final path = await resolveAgentDebugLogPath();
    final file = File(path);
    if (!await file.exists()) {
      return [];
    }
    final lines =
        (await file.readAsString()).split('\n').where((l) => l.trim().isNotEmpty);
    final entries = <Map<String, dynamic>>[];
    for (final line in lines) {
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          entries.add(decoded);
        } else if (decoded is Map) {
          entries.add(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        entries.add({
          'message': 'unparseable line',
          'raw': line,
        });
      }
    }
    return entries;
  } catch (_) {
    return [];
  }
}

Future<String> formatAgentDebugLogForDisplay() async {
  final entries = await readAgentDebugLogEntries();
  if (entries.isEmpty) {
    return '(no diagnostic log entries yet)';
  }
  final buffer = StringBuffer();
  for (final entry in entries) {
    final ts = entry['timestamp'];
    final time = ts is int
        ? DateTime.fromMillisecondsSinceEpoch(ts).toIso8601String()
        : '?';
    buffer.writeln('[$time] ${entry['message'] ?? entry['raw']}');
    if (entry['location'] != null) {
      buffer.writeln('  at ${entry['location']}');
    }
    if (entry['hypothesisId'] != null) {
      buffer.writeln('  hypothesis: ${entry['hypothesisId']}');
    }
    if (entry['runId'] != null) {
      buffer.writeln('  run: ${entry['runId']}');
    }
    final data = entry['data'];
    if (data is Map && data.isNotEmpty) {
      buffer.writeln('  data: ${const JsonEncoder.withIndent('  ').convert(data)}');
    }
    if (entry['raw'] != null) {
      buffer.writeln('  raw: ${entry['raw']}');
    }
    buffer.writeln();
  }
  return buffer.toString().trimRight();
}

Future<void> clearAgentDebugLog() async {
  try {
    final path = await resolveAgentDebugLogPath();
    final file = File(path);
    if (await file.exists()) {
      await file.writeAsString('', flush: true);
    }
  } catch (_) {}
}

Future<AgentDebugLogInfo> getAgentDebugLogInfo() async {
  try {
    final path = await resolveAgentDebugLogPath();
    final file = File(path);
    if (!await file.exists()) {
      return AgentDebugLogInfo(path: path, byteCount: 0, lineCount: 0);
    }
    final content = await file.readAsString();
    final lineCount =
        content.split('\n').where((l) => l.trim().isNotEmpty).length;
    return AgentDebugLogInfo(
      path: path,
      byteCount: content.length,
      lineCount: lineCount,
    );
  } catch (e) {
    return AgentDebugLogInfo(path: e.toString(), byteCount: 0, lineCount: 0);
  }
}

class AgentDebugLogInfo {
  final String path;
  final int byteCount;
  final int lineCount;

  const AgentDebugLogInfo({
    required this.path,
    required this.byteCount,
    required this.lineCount,
  });
}
