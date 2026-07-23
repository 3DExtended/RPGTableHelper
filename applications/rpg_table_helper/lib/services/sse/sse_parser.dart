class SseEvent {
  const SseEvent({required this.type, required this.data});

  final String type;
  final String data;
}

/// Incremental Server-Sent Events parser (text/event-stream).
class SseParser {
  final StringBuffer _buffer = StringBuffer();
  String? _eventType;
  final StringBuffer _data = StringBuffer();

  List<SseEvent> addChunk(String chunk) {
    _buffer.write(chunk);
    final events = <SseEvent>[];

    while (true) {
      final text = _buffer.toString();
      final newline = text.indexOf('\n');
      if (newline < 0) {
        break;
      }

      var line = text.substring(0, newline);
      _buffer
        ..clear()
        ..write(text.substring(newline + 1));

      if (line.endsWith('\r')) {
        line = line.substring(0, line.length - 1);
      }

      if (line.isEmpty) {
        if (_data.isNotEmpty || _eventType != null) {
          events.add(SseEvent(
            type: _eventType ?? 'message',
            data: _data.toString(),
          ));
        }
        _eventType = null;
        _data.clear();
        continue;
      }
      if (line.startsWith(':')) {
        continue;
      }
      if (line.startsWith('event:')) {
        _eventType = line.substring(6).trim();
        continue;
      }
      if (line.startsWith('data:')) {
        if (_data.isNotEmpty) {
          _data.write('\n');
        }
        _data.write(line.substring(5).trimLeft());
      }
    }

    return events;
  }
}
