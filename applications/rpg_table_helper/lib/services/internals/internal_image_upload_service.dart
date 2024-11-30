import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

part 'internal_image_upload_service.chopper.dart';

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
