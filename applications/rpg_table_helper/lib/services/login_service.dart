import 'package:rpg_table_helper/models/humanreadable_response.dart';

abstract class ILoginService {
  final bool isMock;
  const ILoginService({required this.isMock});
  Future<HRResponse<bool>> isAppVersionAllowedToTalkToApi();
}

class LoginService extends ILoginService {
  const LoginService() : super(isMock: false);

  @override
  Future<HRResponse<bool>> isAppVersionAllowedToTalkToApi() {
    // TODO: implement isAppVersionAllowedToTalkToApi
    return Future.value(HRResponse.fromResult(true));
  }
}

class MockLoginService extends ILoginService {
  final bool? isAppVersionAllowedToTalkToApiOverride;
  const MockLoginService({
    this.isAppVersionAllowedToTalkToApiOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<bool>> isAppVersionAllowedToTalkToApi() {
    // TODO: implement isAppVersionAllowedToTalkToApi
    return Future.value(
        HRResponse.fromResult(isAppVersionAllowedToTalkToApiOverride ?? true));
  }
}
