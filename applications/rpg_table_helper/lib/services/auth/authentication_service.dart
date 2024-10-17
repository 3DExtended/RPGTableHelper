import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';
import 'package:rpg_table_helper/services/auth/encryption_service.dart';

enum SignInResult {
  loginFailed,
  loginSucessfullButConfigurationMissing,
  loginSucessfull,
}

abstract class IAuthenticationService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;
  final IEncryptionService encryptionService;

  const IAuthenticationService(
      {required this.isMock,
      required this.apiConnectorService,
      required this.encryptionService});

  /// This returns a JWT for the currently signed in user if possible
  /// This method is also responsible for updating the accesstoke using the refresh token
  Future<HRResponse<String>> getJwtForServerRequest();

  /// This method tries login in to the server using the SignInWithApple functionality.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode});

  /// This method tries signup using username and password.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode});

  /// This method tries login using username and password.
  /// Returns, whether the login was successfull.
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode});
}

class AuthenticationService extends IAuthenticationService {
  const AuthenticationService(
      {required super.apiConnectorService, required super.encryptionService})
      : super(isMock: false);

  @override
  Future<HRResponse<String>> getJwtForServerRequest() {
    // TODO: implement getJwtForServerRequest
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement registerWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }
}

class MockAuthenticationService extends IAuthenticationService {
  final DateTime? nowOverride;
  const MockAuthenticationService({
    required super.apiConnectorService,
    required super.encryptionService,
    this.nowOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<String>> getJwtForServerRequest() {
    // TODO: implement getJwtForServerRequest
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement registerWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }
}
