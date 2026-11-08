import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';

final DateTime _noDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

/// The text and image blocks of a note document in document order.
///
/// The server sets `sortIndex` once a document's blocks are arranged (e.g. by
/// Claude through the player API); blocks it never arranged have none and come
/// first. Blocks with the same position keep their creation order.
List<dynamic> sortNoteBlocksInDocumentOrder(Iterable<dynamic> blocks) {
  final sorted = List<dynamic>.from(blocks);
  sorted.sort((a, b) {
    final (indexA, createdA) = _orderKey(a);
    final (indexB, createdB) = _orderKey(b);
    final byIndex = indexA.compareTo(indexB);
    return byIndex != 0 ? byIndex : createdA.compareTo(createdB);
  });
  return sorted;
}

(int, DateTime) _orderKey(Object? block) => switch (block) {
      TextBlock b => (b.sortIndex ?? -1, b.creationDate ?? _noDate),
      ImageBlock b => (b.sortIndex ?? -1, b.creationDate ?? _noDate),
      _ => (-1, _noDate),
    };
