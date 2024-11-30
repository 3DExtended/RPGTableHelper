import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

@ChopperApi()
abstract class InternalImageUploadService extends ChopperService {
  @Post(path: '/Image/streamimageupload')
  @multipart
  Future<Response<String>> uploadImage(
    @Query('campagneId') String campagneId,
    @PartFile('image') http.MultipartFile image,
  );

  static InternalImageUploadService create([ChopperClient? client]) =>
      _$InternalImageUploadService(client);
}

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
