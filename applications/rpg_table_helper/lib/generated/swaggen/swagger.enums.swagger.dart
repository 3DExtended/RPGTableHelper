import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum HandleJoinRequestType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('Accept')
  accept('Accept'),
  @JsonValue('Deny')
  deny('Deny');

  final String? value;

  const HandleJoinRequestType(this.value);
}

enum ImageType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('Undefined')
  undefined('Undefined'),
  @JsonValue('PNG')
  png('PNG'),
  @JsonValue('JPEG')
  jpeg('JPEG');

  final String? value;

  const ImageType(this.value);
}
