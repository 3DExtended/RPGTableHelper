import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/note_block_order.dart';

TextBlock _text(String text, DateTime created, {int? sortIndex}) =>
    TextBlock(markdownText: text, creationDate: created, sortIndex: sortIndex);

ImageBlock _image(String caption, DateTime created, {int? sortIndex}) =>
    ImageBlock(
      markdownText: caption,
      creationDate: created,
      sortIndex: sortIndex,
      publicImageUrl: '/images/$caption.png',
      imageMetaDataId: const ImageMetaDataIdentifier(value: 'img'),
    );

String _label(dynamic block) => switch (block) {
      TextBlock b => b.markdownText!,
      ImageBlock b => b.markdownText!,
      _ => '?',
    };

void main() {
  final monday = DateTime.utc(2026, 11, 2);
  final tuesday = DateTime.utc(2026, 11, 3);
  final wednesday = DateTime.utc(2026, 11, 4);

  test('without positions, blocks keep their creation order', () {
    final sorted = sortNoteBlocksInDocumentOrder([
      _image('map', tuesday),
      _text('intro', monday),
      _text('end', wednesday),
    ]);

    expect(sorted.map(_label), ['intro', 'map', 'end']);
  });

  test('arranged blocks follow their position, not their age', () {
    final sorted = sortNoteBlocksInDocumentOrder([
      _text('intro', monday, sortIndex: 2),
      _image('map', tuesday, sortIndex: 0),
      _text('end', wednesday, sortIndex: 1),
    ]);

    expect(sorted.map(_label), ['map', 'end', 'intro']);
  });

  test('blocks without a position come before arranged ones', () {
    final sorted = sortNoteBlocksInDocumentOrder([
      _text('arranged', monday, sortIndex: 0),
      _text('old', tuesday),
    ]);

    expect(sorted.map(_label), ['old', 'arranged']);
  });
}
