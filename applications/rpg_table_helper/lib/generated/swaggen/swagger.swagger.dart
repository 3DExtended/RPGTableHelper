// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'swagger.models.swagger.dart';
import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
export 'swagger.models.swagger.dart';

part 'swagger.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Swagger extends ChopperService {
  static Swagger create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Swagger(client);
    }

    final newClient = ChopperClient(
        services: [_$Swagger()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://'));
    return _$Swagger(newClient);
  }

  ///Creates a new campagne with the calling user as dm.
  Future<chopper.Response<CampagneIdentifier>> campagneCreatecampagnePost(
      {required CampagneCreateDto? body}) {
    generatedMapping.putIfAbsent(
        CampagneIdentifier, () => CampagneIdentifier.fromJsonFactory);

    return _campagneCreatecampagnePost(body: body);
  }

  ///Creates a new campagne with the calling user as dm.
  @Post(
    path: '/Campagne/createcampagne',
    optionalBody: true,
  )
  Future<chopper.Response<CampagneIdentifier>> _campagneCreatecampagnePost(
      {@Body() required CampagneCreateDto? body});

  ///Returns a list of campagnes this user is the dm of.
  Future<chopper.Response<List<Campagne>>> campagneGetcampagnesGet() {
    generatedMapping.putIfAbsent(Campagne, () => Campagne.fromJsonFactory);

    return _campagneGetcampagnesGet();
  }

  ///Returns a list of campagnes this user is the dm of.
  @Get(path: '/Campagne/getcampagnes')
  Future<chopper.Response<List<Campagne>>> _campagneGetcampagnesGet();

  ///Returns a single of campagne.
  ///@param campagneid The id of the desired campagne
  Future<chopper.Response<Campagne>> campagneGetcampagneCampagneidGet(
      {required String? campagneid}) {
    generatedMapping.putIfAbsent(Campagne, () => Campagne.fromJsonFactory);

    return _campagneGetcampagneCampagneidGet(campagneid: campagneid);
  }

  ///Returns a single of campagne.
  ///@param campagneid The id of the desired campagne
  @Get(path: '/Campagne/getcampagne/{campagneid}')
  Future<chopper.Response<Campagne>> _campagneGetcampagneCampagneidGet(
      {@Path('campagneid') required String? campagneid});

  ///Creates a new player character with the calling user as owner.
  Future<chopper.Response<PlayerCharacterIdentifier>>
      playerCharacterCreatecharacterPost(
          {required PlayerCharacterCreateDto? body}) {
    generatedMapping.putIfAbsent(PlayerCharacterIdentifier,
        () => PlayerCharacterIdentifier.fromJsonFactory);

    return _playerCharacterCreatecharacterPost(body: body);
  }

  ///Creates a new player character with the calling user as owner.
  @Post(
    path: '/PlayerCharacter/createcharacter',
    optionalBody: true,
  )
  Future<chopper.Response<PlayerCharacterIdentifier>>
      _playerCharacterCreatecharacterPost(
          {@Body() required PlayerCharacterCreateDto? body});

  ///Returns a list of player characters for the calling user.
  Future<chopper.Response<List<PlayerCharacter>>>
      playerCharacterGetplayercharactersGet() {
    generatedMapping.putIfAbsent(
        PlayerCharacter, () => PlayerCharacter.fromJsonFactory);

    return _playerCharacterGetplayercharactersGet();
  }

  ///Returns a list of player characters for the calling user.
  @Get(path: '/PlayerCharacter/getplayercharacters')
  Future<chopper.Response<List<PlayerCharacter>>>
      _playerCharacterGetplayercharactersGet();

  ///Returns a single playerCharacter.
  ///@param playercharacterid The id of the desired playerCharacter
  Future<chopper.Response<PlayerCharacter>>
      playerCharacterGetplayercharacterPlayercharacteridGet(
          {required String? playercharacterid}) {
    generatedMapping.putIfAbsent(
        PlayerCharacter, () => PlayerCharacter.fromJsonFactory);

    return _playerCharacterGetplayercharacterPlayercharacteridGet(
        playercharacterid: playercharacterid);
  }

  ///Returns a single playerCharacter.
  ///@param playercharacterid The id of the desired playerCharacter
  @Get(path: '/PlayerCharacter/getplayercharacter/{playercharacterid}')
  Future<chopper.Response<PlayerCharacter>>
      _playerCharacterGetplayercharacterPlayercharacteridGet(
          {@Path('playercharacterid') required String? playercharacterid});

  ///Returns the minimal app version supported by this api.
  Future<chopper.Response<String>> publicGetminimalversionGet() {
    return _publicGetminimalversionGet();
  }

  ///Returns the minimal app version supported by this api.
  @Get(path: '/Public/getminimalversion')
  Future<chopper.Response<String>> _publicGetminimalversionGet();

  ///This method generates a new encryptionChallenge and stores it in the db.
  ///Use this method as first start point for a register operation.
  Future<chopper.Response<String>> registerCreateencryptionchallengePost(
      {required String? body}) {
    return _registerCreateencryptionchallengePost(body: body);
  }

  ///This method generates a new encryptionChallenge and stores it in the db.
  ///Use this method as first start point for a register operation.
  @Post(
    path: '/Register/createencryptionchallenge',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _registerCreateencryptionchallengePost(
      {@Body() required String? body});

  ///Creates a new user with "username and password" sign in.
  Future<chopper.Response<String>> registerRegisterPost(
      {required String? body}) {
    return _registerRegisterPost(body: body);
  }

  ///Creates a new user with "username and password" sign in.
  @Post(
    path: '/Register/register',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _registerRegisterPost(
      {@Body() required String? body});

  ///Creates a new user for an open sign OpenSignInProviderRegisterRequest.
  Future<chopper.Response<String>> registerRegisterwithapikeyPost(
      {required RegisterWithApiKeyDto? body}) {
    return _registerRegisterwithapikeyPost(body: body);
  }

  ///Creates a new user for an open sign OpenSignInProviderRegisterRequest.
  @Post(
    path: '/Register/registerwithapikey',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _registerRegisterwithapikeyPost(
      {@Body() required RegisterWithApiKeyDto? body});

  ///Lets the user verify their email.
  ///@param useridbase64 The base64 encoded userid
  ///@param signaturebase64 The server generated signature for the userid
  Future<chopper.Response<String>>
      registerVerifyemailUseridbase64Signaturebase64Get({
    required String? useridbase64,
    required String? signaturebase64,
  }) {
    return _registerVerifyemailUseridbase64Signaturebase64Get(
        useridbase64: useridbase64, signaturebase64: signaturebase64);
  }

  ///Lets the user verify their email.
  ///@param useridbase64 The base64 encoded userid
  ///@param signaturebase64 The server generated signature for the userid
  @Get(path: '/Register/verifyemail/{useridbase64}/{signaturebase64}')
  Future<chopper.Response<String>>
      _registerVerifyemailUseridbase64Signaturebase64Get({
    @Path('useridbase64') required String? useridbase64,
    @Path('signaturebase64') required String? signaturebase64,
  });

  ///This method returns "Welcome" when the provided JWT is valid.
  Future<chopper.Response<String>> signInTestloginGet() {
    return _signInTestloginGet();
  }

  ///This method returns "Welcome" when the provided JWT is valid.
  @Get(path: '/SignIn/testlogin')
  Future<chopper.Response<String>> _signInTestloginGet();

  ///Returns the encryption challenge for a given username.
  ///@param username The username of the desired encryption challenge
  Future<chopper.Response<String>>
      signInGetloginchallengeforusernameUsernamePost({
    required String? username,
    required EncryptedMessageWrapperDto? body,
  }) {
    return _signInGetloginchallengeforusernameUsernamePost(
        username: username, body: body);
  }

  ///Returns the encryption challenge for a given username.
  ///@param username The username of the desired encryption challenge
  @Post(
    path: '/SignIn/getloginchallengeforusername/{username}',
    optionalBody: true,
  )
  Future<chopper.Response<String>>
      _signInGetloginchallengeforusernameUsernamePost({
    @Path('username') required String? username,
    @Body() required EncryptedMessageWrapperDto? body,
  });

  ///Performs the login with username and password.
  Future<chopper.Response<String>> signInLoginPost(
      {required LoginWithUsernameAndPasswordDto? body}) {
    return _signInLoginPost(body: body);
  }

  ///Performs the login with username and password.
  @Post(
    path: '/SignIn/login',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _signInLoginPost(
      {@Body() required LoginWithUsernameAndPasswordDto? body});

  ///
  Future<chopper.Response<String>> signInLoginwithapplePost(
      {required AppleLoginDetails? body}) {
    return _signInLoginwithapplePost(body: body);
  }

  ///
  @Post(
    path: '/SignIn/loginwithapple',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _signInLoginwithapplePost(
      {@Body() required AppleLoginDetails? body});

  ///
  Future<chopper.Response<String>> signInLoginwithgooglePost(
      {required GoogleLoginDto? body}) {
    return _signInLoginwithgooglePost(body: body);
  }

  ///
  @Post(
    path: '/SignIn/loginwithgoogle',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _signInLoginwithgooglePost(
      {@Body() required GoogleLoginDto? body});

  ///Requests an reset password email for the user.
  Future<chopper.Response<String>> signInRequestresetpasswordPost(
      {required ResetPasswordRequestDto? body}) {
    return _signInRequestresetpasswordPost(body: body);
  }

  ///Requests an reset password email for the user.
  @Post(
    path: '/SignIn/requestresetpassword',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _signInRequestresetpasswordPost(
      {@Body() required ResetPasswordRequestDto? body});

  ///Completes the password reset requests by providing the reset code from the email.
  Future<chopper.Response<String>> signInResetpasswordPost(
      {required ResetPasswordDto? body}) {
    return _signInResetpasswordPost(body: body);
  }

  ///Completes the password reset requests by providing the reset code from the email.
  @Post(
    path: '/SignIn/resetpassword',
    optionalBody: true,
  )
  Future<chopper.Response<String>> _signInResetpasswordPost(
      {@Body() required ResetPasswordDto? body});
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
      chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
