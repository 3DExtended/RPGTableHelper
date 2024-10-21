import 'dart:convert';

import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.swagger.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';
import 'package:rpg_table_helper/services/auth/encryption_service.dart';
import 'package:rpg_table_helper/services/auth/rsa_key_helper.dart';

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

  /// This method tries login in to the server using the SignInWithApple functionality.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode});

  /// This method tries login in to the server using the SignInWithGoogle functionality.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> signInWithGoogle(
      {required String identityToken, required String authorizationCode});

  /// This method tries signup using username and password.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword({
    required String username,
    required String email,
    required String password,
  });

  /// This method tries login using username and password.
  /// Returns, whether the login was successfull.
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String username, required String password});
}

class AuthenticationService extends IAuthenticationService {
  const AuthenticationService(
      {required super.apiConnectorService, required super.encryptionService})
      : super(isMock: false);

  @override
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String username, required String password}) async {
    // TODO show loading spinner???

    var client = await apiConnectorService.getApiConnector(
      requiresJwt: false, // as we try to obtain a jwt!
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "c369c269-6628-4c82-978e-6fd85a4c0fcd");
    }

    // 0. we need to generate a public and private key pair for this app client
    var keyPairTuple = await encryptionService.getKeysAndPublicPem();

    // 1. we need to load the encyption challenge for the user
    var encryptionChallengeResult = await HRResponse.fromApiFuture(
        client.signInGetloginchallengeforusernameUsernamePost(
            username: username,
            body: EncryptedMessageWrapperDto(
              encryptedMessage: keyPairTuple.$2,
            )),
        "Could not load encryption challenge for login request",
        "9c8a0470-486a-4b0e-83cd-0f20636671e7");

    if (!encryptionChallengeResult.isSuccessful) {
      return encryptionChallengeResult.asT();
    }

    // 2. we need to encrypt the password with it
    var encryptedMessage = encryptionChallengeResult.result;
    var decryptedMessage =
        RsaKeyHelper.decrypt(encryptedMessage!, keyPairTuple.$1);

    Map<String, dynamic> challenge = jsonDecode(decryptedMessage);

    String hashedPassword = encryptionService
        .calculateUserSecretForEncryptionChallenge(challenge, password);

    var result = await HRResponse.fromApiFuture(
        client.signInLoginPost(
            body: LoginWithUsernameAndPasswordDto(
          username: username,
          userSecretByEncryptionChallenge: hashedPassword,
        )),
        "Could not login with username and password.",
        "cb704a30-c113-424f-9f51-bc11f0dd479c");

    if (!result.isSuccessful) {
      return HRResponse.fromResult(true, statusCode: result.statusCode);
    }

    await apiConnectorService.setJwt(result.result!);

    return result.asT();
  }

  @override
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    var client = await apiConnectorService.getApiConnector(
      requiresJwt: false, // as we try to obtain a jwt!
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "d6876051-c66d-462d-a0ef-35e43d646bbf");
    }

    // 0. we need to generate a public and private key pair for this app client
    var keyPairTuple = await encryptionService.getKeysAndPublicPem();

    // 1. we need to load the encyption challenge for the user
    var encryptionChallengeResult = await HRResponse.fromApiFuture(
        client.registerCreateencryptionchallengePost(
          body: keyPairTuple.$2,
        ),
        "Could not load encryption challenge for register request",
        "3679927b-e32a-42f6-b3dd-6c22687d3952");

    if (!encryptionChallengeResult.isSuccessful) {
      return encryptionChallengeResult.asT();
    }

    var encryptedMessage = encryptionChallengeResult.result;
    var decryptedMessage =
        RsaKeyHelper.decrypt(encryptedMessage!, keyPairTuple.$1);

    Map<String, dynamic> challenge = jsonDecode(decryptedMessage);
    String userSecret = encryptionService
        .calculateUserSecretForEncryptionChallenge(challenge, password);

    Map<String, dynamic> encryptedRegisterObj = {};

    encryptedRegisterObj['email'] = email;
    encryptedRegisterObj['username'] = username;
    encryptedRegisterObj['userSecret'] = userSecret;
    encryptedRegisterObj['encryptionChallengeIdentifier'] = {
      'value': challenge['id']
    };

    var jsonObject = jsonEncode(encryptedRegisterObj);

    // encrypt with serPub key
    var serPubKey =
        RsaKeyHelper.parsePublicKeyFromPem(rpgtablehelperPublicCertificate);

    var encryptedObj = RsaKeyHelper.encrypt(jsonObject, serPubKey);
    var registerResult = await HRResponse.fromApiFuture(
        client.registerRegisterPost(body: encryptedObj),
        "Could not register new user on server",
        "7794b7bf-59c7-4f0b-9334-b613b18d62f1");

    // THIS might return a statuscode 409 indicating that the username is taken
    if (!registerResult.isSuccessful) {
      return registerResult.asT<SignInResult>();
    }

    // set jwt!
    apiConnectorService.setJwt(registerResult.result!);

    return HRResponse.fromResult(
      SignInResult.loginSucessfull,
      statusCode: registerResult.statusCode,
    );
  }

  @override
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithGoogle(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithGoogle
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
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String username, required String password}) {
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword({
    required String username,
    required String email,
    required String password,
  }) {
    // TODO: implement registerWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithGoogle(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }
}
