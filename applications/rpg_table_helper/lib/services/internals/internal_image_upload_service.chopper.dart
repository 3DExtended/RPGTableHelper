// Generated code

part of 'internal_image_upload_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$InternalImageUploadService extends InternalImageUploadService {
  _$InternalImageUploadService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = InternalImageUploadService;

  @override
  Future<Response<String>> uploadImage(
    String campagneId,
    http.MultipartFile image,
  ) {
    final Uri $url = Uri.parse('/Image/streamimageupload');
    final Map<String, dynamic> $params = <String, dynamic>{
      'campagneId': campagneId
    };
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<http.MultipartFile>(
        'image',
        image,
      )
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      parameters: $params,
    );
    return client.send<String, String>($request);
  }
}
