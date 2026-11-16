import 'dart:convert';

import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/rsa_key_helper.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

enum SignInResultType {
  loginFailed,
  loginSucessfullButConfigurationMissing,
  loginSucessfull,
}

class SignInResult {
  final SignInResultType resultType;
  final String? additionalDetails;

  SignInResult({required this.resultType, this.additionalDetails});
}

abstract class IAuthenticationService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;
  final IEncryptionService encryptionService;
  final ISecureRefreshTokenStorage secureRefreshTokenStorage;
  final IAccessTokenExpiryStore accessTokenExpiryStore;
  final ISystemClockService systemClockService;

  const IAuthenticationService(
      {required this.isMock,
      required this.apiConnectorService,
      required this.encryptionService,
      required this.secureRefreshTokenStorage,
      required this.accessTokenExpiryStore,
      required this.systemClockService});

  /// This method tries login in to the server using the SignInWithApple functionality.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken, required String authorizationCode});

  Future<HRResponse<bool>> completeRegistration(
      {required String apiKey, required String username});

  /// This method tries login in to the server using the SignInWithGoogle functionality.
  /// Returns, whether the login was successfull and the user is a fully registered user or if there is the configuration missing
  Future<HRResponse<SignInResult>> signInWithGoogle(
      {required String identityToken, required String authorizationCode});

  Future<HRResponse<bool>> testLogin();

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

  /// Asks the server to email a password reset code to the user. The server
  /// only sends it when [username] and [email] belong to the same password
  /// account (not to accounts that sign in with Apple or Google).
  Future<HRResponse<bool>> requestPasswordReset(
      {required String username, required String email});

  /// Sets [newPassword] for the user, using the [resetCode] from the email.
  ///
  /// The password is turned into the same user secret as at registration and
  /// login, so the user can sign in with the new password right away.
  Future<HRResponse<bool>> resetPassword({
    required String username,
    required String email,
    required String resetCode,
    required String newPassword,
  });
}

class AuthenticationService extends IAuthenticationService {
  const AuthenticationService({
    required super.apiConnectorService,
    required super.encryptionService,
    required super.secureRefreshTokenStorage,
    required super.accessTokenExpiryStore,
    required super.systemClockService,
  }) : super(isMock: false);

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

    var hashedPasswordResult = await _userSecretForExistingUser(
      client,
      username: username,
      password: password,
      humanReadableError:
          "Could not load encryption challenge for login request",
      errorCode: "9c8a0470-486a-4b0e-83cd-0f20636671e7",
    );
    if (!hashedPasswordResult.isSuccessful) {
      return hashedPasswordResult.asT();
    }
    var hashedPassword = hashedPasswordResult.result!;

    var result = await HRResponse.fromApiFuture(
        client.signInLoginPost(
            body: LoginWithUsernameAndPasswordDto(
          username: username,
          userSecretByEncryptionChallenge: hashedPassword,
        )),
        "Could not login with username and password.",
        "cb704a30-c113-424f-9f51-bc11f0dd479c");

    // A wrong username or password must not count as a successful login.
    if (!result.isSuccessful) {
      return result.asT();
    }

    await persistTokenPair(result.result!);

    return HRResponse.fromResult(true, statusCode: result.statusCode);
  }

  /// Derives the user secret the server stores for a password account.
  ///
  /// Registration hashes the password with the user's encryption challenge,
  /// and the server keeps that challenge linked to the user. Login and
  /// password reset load it again by username and hash the same way, so the
  /// server can compare (login) or replace (reset) the stored secret.
  Future<HRResponse<String>> _userSecretForExistingUser(
    Swagger client, {
    required String username,
    required String password,
    required String humanReadableError,
    required String errorCode,
  }) async {
    // 0. we need to generate a public and private key pair for this app client
    var keyPairTuple = await encryptionService.getKeysAndPublicPem();

    // 1. we need to load the encyption challenge for the user
    var encryptionChallengeResult = await HRResponse.fromApiFuture(
        client.signInGetloginchallengeforusernameUsernamePost(
            username: username,
            body: EncryptedMessageWrapperDto(
              encryptedMessage: keyPairTuple.$2,
            )),
        humanReadableError,
        errorCode);

    if (!encryptionChallengeResult.isSuccessful) {
      return encryptionChallengeResult.asT();
    }

    // 2. we need to encrypt the password with it
    var encryptedMessage = encryptionChallengeResult.result;
    var decryptedMessage =
        RsaKeyHelper.decrypt(encryptedMessage!, keyPairTuple.$1);

    Map<String, dynamic> challenge = jsonDecode(decryptedMessage);

    return HRResponse.fromResult(
      encryptionService.calculateUserSecretForEncryptionChallenge(
          challenge, password),
      statusCode: encryptionChallengeResult.statusCode,
    );
  }

  @override
  Future<HRResponse<bool>> requestPasswordReset(
      {required String username, required String email}) async {
    var client = await apiConnectorService.getApiConnector(
      requiresJwt: false, // the user is not signed in
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "0d5e0b8e-5d0b-4d6c-9f5e-2f3c8a1e7b41");
    }

    var result = await HRResponse.fromApiFuture(
        client.signInRequestresetpasswordPost(
            body: ResetPasswordRequestDto(email: email, username: username)),
        "Could not request a password reset code.",
        "a7f3c2d1-4b6e-4e8a-9c0d-5f1b2e3a4c5d");

    if (!result.isSuccessful) return result.asT();

    return HRResponse.fromResult(true, statusCode: result.statusCode);
  }

  @override
  Future<HRResponse<bool>> resetPassword({
    required String username,
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    var client = await apiConnectorService.getApiConnector(
      requiresJwt: false, // the user is not signed in
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "3c9e1f7a-2b8d-4a6c-8e0f-1d2c3b4a5e6f");
    }

    // The server stores the new value as it is, so it has to be the same
    // user secret that login sends for this password.
    var newUserSecretResult = await _userSecretForExistingUser(
      client,
      username: username,
      password: newPassword,
      humanReadableError:
          "Could not load encryption challenge for password reset",
      errorCode: "8b2d4f6a-1c3e-4a5b-9d7f-0e2a4c6b8d1f",
    );
    if (!newUserSecretResult.isSuccessful) {
      return newUserSecretResult.asT();
    }

    var result = await HRResponse.fromApiFuture(
        client.signInResetpasswordPost(
            body: ResetPasswordDto(
          email: email,
          newHashedPassword: newUserSecretResult.result!,
          resetCode: resetCode,
          username: username,
        )),
        "Could not reset the password.",
        "e4a6c8b0-3d5f-4e7a-8c9b-2a1d3f5e7c9b");

    if (!result.isSuccessful) return result.asT();

    return HRResponse.fromResult(true, statusCode: result.statusCode);
  }

  /// Parses the `{ accessToken, refreshToken, expiresIn }` JSON body returned
  /// by password login and persists all three: the access JWT via
  /// [IApiConnectorService.setJwt] (SharedPreferences), the refresh token via
  /// [ISecureRefreshTokenStorage] (secure storage), and the absolute access
  /// token expiry (now + `expiresIn` seconds) via [IAccessTokenExpiryStore],
  /// which [SessionRefreshCoordinator] later uses to schedule proactive
  /// refresh.
  Future<void> persistTokenPair(String rawTokenPairJson) async {
    var tokenPair = jsonDecode(rawTokenPairJson) as Map<String, dynamic>;
    var accessToken = tokenPair['accessToken'] as String;
    var refreshToken = tokenPair['refreshToken'] as String;

    await apiConnectorService.setJwt(accessToken);
    await secureRefreshTokenStorage.setRefreshToken(refreshToken);

    var expiresIn = tokenPair['expiresIn'];
    if (expiresIn is num) {
      await accessTokenExpiryStore.setExpiry(
        systemClockService.now().add(Duration(seconds: expiresIn.toInt())),
      );
    }

    apiConnectorService.clearCache();
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

    await persistTokenPair(registerResult.result!);

    return HRResponse.fromResult(
      SignInResult(resultType: SignInResultType.loginSucessfull),
      statusCode: registerResult.statusCode,
    );
  }

  @override
  Future<HRResponse<SignInResult>> signInWithApple(
      {required String identityToken,
      required String authorizationCode}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: false);
    if (api == null) {
      return HRResponse.error<SignInResult>('Could not load api connector.',
          'e7771d09-b2f5-4ea2-b0a7-8bebd0298d96');
    }

    // load loginChallenge for username
    var loginWithAppleResult = await HRResponse.fromApiFuture(
        api.signInLoginwithapplePost(
          body: AppleLoginDetails(
            authorizationCode: authorizationCode,
            identityToken: identityToken,
          ),
        ),
        'Could not login using apple sign in.',
        '6b89a5e7-5ada-4a75-b574-c248ed0a59b2');

    if (!loginWithAppleResult.isSuccessful) {
      return loginWithAppleResult.asT<SignInResult>();
    }

    if (loginWithAppleResult.isSuccessful &&
        loginWithAppleResult.result != null &&
        loginWithAppleResult.result!.startsWith('redirect')) {
      return HRResponse.fromResult(
        SignInResult(
          resultType: SignInResultType.loginSucessfullButConfigurationMissing,
          additionalDetails:
              loginWithAppleResult.result!.replaceAll('redirect', ''),
        ),
        statusCode: loginWithAppleResult.statusCode,
      );
    } else if (loginWithAppleResult.isSuccessful) {
      // Do NOT wrap Future<void> in HRResponse.fromFuture — void completes as
      // null and fromFuture treats that as failure (broke Apple login after
      // token-pair auth). Await directly like password/register paths.
      try {
        await persistTokenPair(loginWithAppleResult.result!);
      } catch (e) {
        return HRResponse.error<SignInResult>(
          'Could not update jwt.',
          '58b6c194-7aaa-4fdf-810a-09ec6a684731',
          caughtException: e is Exception ? e : Exception(e.toString()),
        );
      }

      return HRResponse.fromResult(
        SignInResult(
          resultType: SignInResultType.loginSucessfull,
        ),
        statusCode: loginWithAppleResult.statusCode,
      );
    }

    return loginWithAppleResult.asT<SignInResult>();
  }

  @override
  Future<HRResponse<SignInResult>> signInWithGoogle(
      {required String identityToken, required String authorizationCode}) {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> testLogin() async {
    var client = await apiConnectorService.getApiConnector(
      requiresJwt: true, // require a jwt for testing the login
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "06f9a01d-cf2d-4308-9b2d-95d306968386");
    }

    var result = await HRResponse.fromApiFuture(
        client.signInTestloginGet(),
        "Testing for a valid jwt failed.",
        "844f0aa1-8dd8-45ed-8540-a98ad8906e07");

    if (!result.isSuccessful) return result.asT();

    return HRResponse.fromResult(true, statusCode: result.statusCode);
  }

  @override
  Future<HRResponse<bool>> completeRegistration(
      {required String apiKey, required String username}) async {
    var client = await apiConnectorService.getApiConnector(
      requiresJwt: false, // doesnt require a jwt since apiKey is set
    );
    if (client == null) {
      return HRResponse.error("Could not load apiConnectorClient",
          "78a6f9b5-18fe-4107-9378-10fdf1de3c3d");
    }

    var result = await HRResponse.fromApiFuture(
        client.registerRegisterwithapikeyPost(
            body: RegisterWithApiKeyDto(apiKey: apiKey, username: username)),
        "Could not complete registration for sign in provider.",
        "55c7e10c-118b-4de1-9407-16b7800c9bcd");

    if (!result.isSuccessful) return result.asT();

    await persistTokenPair(result.result!);

    return HRResponse.fromResult(true, statusCode: result.statusCode);
  }
}

class MockAuthenticationService extends IAuthenticationService {
  final DateTime? nowOverride;

  /// Returned by [loginWithUsernameAndPassword]; unset keeps the old
  /// "not implemented" behaviour.
  final HRResponse<bool>? loginResultOverride;

  /// Returned by [registerWithUsernameAndPassword]; unset keeps the old
  /// "not implemented" behaviour.
  final HRResponse<SignInResult>? registerResultOverride;

  /// Returned by [requestPasswordReset]; defaults to success.
  final HRResponse<bool>? requestPasswordResetResultOverride;

  /// Returned by [resetPassword]; defaults to success.
  final HRResponse<bool>? resetPasswordResultOverride;

  final List<({String username, String password})> loginCalls = [];
  final List<({String username, String email, String password})>
      registerCalls = [];
  final List<({String username, String email})> requestPasswordResetCalls =
      [];
  final List<
      ({
        String username,
        String email,
        String resetCode,
        String newPassword
      })> resetPasswordCalls = [];

  MockAuthenticationService({
    required super.apiConnectorService,
    required super.encryptionService,
    required super.secureRefreshTokenStorage,
    required super.accessTokenExpiryStore,
    required super.systemClockService,
    this.nowOverride,
    this.loginResultOverride,
    this.registerResultOverride,
    this.requestPasswordResetResultOverride,
    this.resetPasswordResultOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<bool>> loginWithUsernameAndPassword(
      {required String username, required String password}) async {
    loginCalls.add((username: username, password: password));
    if (loginResultOverride != null) return loginResultOverride!;
    // TODO: implement loginWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<SignInResult>> registerWithUsernameAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    registerCalls.add((username: username, email: email, password: password));
    if (registerResultOverride != null) return registerResultOverride!;
    // TODO: implement registerWithUsernameAndPassword
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> requestPasswordReset(
      {required String username, required String email}) async {
    requestPasswordResetCalls.add((username: username, email: email));
    return requestPasswordResetResultOverride ?? HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> resetPassword({
    required String username,
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    resetPasswordCalls.add((
      username: username,
      email: email,
      resetCode: resetCode,
      newPassword: newPassword,
    ));
    return resetPasswordResultOverride ?? HRResponse.fromResult(true);
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

  @override
  Future<HRResponse<bool>> testLogin() {
    // TODO: implement testLogin
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> completeRegistration(
      {required String apiKey, required String username}) {
    // TODO: implement completeRegistration
    throw UnimplementedError();
  }
}
