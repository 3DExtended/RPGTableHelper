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
