import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'connection_details.g.dart';

@JsonSerializable()
@CopyWith()
class ConnectionDetails {
  final bool isConnected;
  final bool isConnecting;
  final String? sessionConnectionNumberForPlayers;
  final bool isDm;

  ConnectionDetails({
    required this.isConnected,
    required this.sessionConnectionNumberForPlayers,
    required this.isConnecting,
    required this.isDm,
  });

  static ConnectionDetails defaultValue() => ConnectionDetails(
        isConnected: false,
        isConnecting: false,
        isDm: false,
        sessionConnectionNumberForPlayers: null,
      );

  bool get isPlayer => !isDm;

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) =>
      _$ConnectionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionDetailsToJson(this);
}
