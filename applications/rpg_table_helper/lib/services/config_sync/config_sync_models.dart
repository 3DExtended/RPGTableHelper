/// Mirrors the API's `ConfigWriteResultDto` (`{ revision }`).
class ConfigWriteResult {
  const ConfigWriteResult({required this.revision});

  final int revision;

  factory ConfigWriteResult.fromJson(Map<String, dynamic> json) =>
      ConfigWriteResult(revision: json['revision'] as int);
}

/// Mirrors the API's `ConfigSnapshotResponseDto` returned by
/// `GET .../config/{id}?sinceRevision=`.
///
/// [kind] is either `"patch"` (an RFC 6902 JSON Patch array in [patch],
/// to be applied on top of the caller's copy at [fromRevision]) or `"full"`
/// (the complete document JSON in [fullConfig]).
class ConfigSnapshot {
  const ConfigSnapshot({
    required this.kind,
    required this.revision,
    this.fromRevision,
    this.fullConfig,
    this.patch,
  });

  final String kind;
  final int revision;
  final int? fromRevision;
  final String? fullConfig;
  final String? patch;

  bool get isFull => kind == 'full';
  bool get isPatch => kind == 'patch';

  factory ConfigSnapshot.fromJson(Map<String, dynamic> json) =>
      ConfigSnapshot(
        kind: json['kind'] as String,
        revision: json['revision'] as int,
        fromRevision: json['fromRevision'] as int?,
        fullConfig: json['fullConfig'] as String?,
        patch: json['patch'] as String?,
      );
}
