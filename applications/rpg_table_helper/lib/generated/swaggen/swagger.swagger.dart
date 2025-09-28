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
import 'swagger.enums.swagger.dart' as enums;
export 'swagger.enums.swagger.dart';
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
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$Swagger(newClient);
  }

  ///Creates a new campagne with the calling user as dm.
  Future<chopper.Response<CampagneIdentifier>> campagneCreatecampagnePost({
    required CampagneCreateDto? body,
  }) {
    generatedMapping.putIfAbsent(
      CampagneIdentifier,
      () => CampagneIdentifier.fromJsonFactory,
    );

    return _campagneCreatecampagnePost(body: body);
  }

  ///Creates a new campagne with the calling user as dm.
  @POST(path: '/Campagne/createcampagne', optionalBody: true)
  Future<chopper.Response<CampagneIdentifier>> _campagneCreatecampagnePost({
    @Body() required CampagneCreateDto? body,
  });

  ///Returns a list of campagnes this user is the dm of.
  Future<chopper.Response<List<Campagne>>> campagneGetcampagnesGet() {
    generatedMapping.putIfAbsent(Campagne, () => Campagne.fromJsonFactory);

    return _campagneGetcampagnesGet();
  }

  ///Returns a list of campagnes this user is the dm of.
  @GET(path: '/Campagne/getcampagnes')
  Future<chopper.Response<List<Campagne>>> _campagneGetcampagnesGet();

  ///Returns a single of campagne.
  ///@param campagneid The id of the desired campagne
  Future<chopper.Response<Campagne>> campagneGetcampagneCampagneidGet({
    required String? campagneid,
  }) {
    generatedMapping.putIfAbsent(Campagne, () => Campagne.fromJsonFactory);

    return _campagneGetcampagneCampagneidGet(campagneid: campagneid);
  }

  ///Returns a single of campagne.
  ///@param campagneid The id of the desired campagne
  @GET(path: '/Campagne/getcampagne/{campagneid}')
  Future<chopper.Response<Campagne>> _campagneGetcampagneCampagneidGet({
    @Path('campagneid') required String? campagneid,
  });

  ///Creates a new campagneJoinRequest with the calling user as dm.
  Future<chopper.Response<CampagneJoinRequestIdentifier>>
  campagneJoinRequestCreatecampagneJoinRequestPost({
    required CampagneJoinRequestCreateDto? body,
  }) {
    generatedMapping.putIfAbsent(
      CampagneJoinRequestIdentifier,
      () => CampagneJoinRequestIdentifier.fromJsonFactory,
    );

    return _campagneJoinRequestCreatecampagneJoinRequestPost(body: body);
  }

  ///Creates a new campagneJoinRequest with the calling user as dm.
  @POST(
    path: '/CampagneJoinRequest/createcampagneJoinRequest',
    optionalBody: true,
  )
  Future<chopper.Response<CampagneJoinRequestIdentifier>>
  _campagneJoinRequestCreatecampagneJoinRequestPost({
    @Body() required CampagneJoinRequestCreateDto? body,
  });

  ///Accepts or denies a campagneJoinRequest with the calling user as dm.
  Future<chopper.Response> campagneJoinRequestHandlejoinrequestPost({
    required HandleJoinRequestDto? body,
  }) {
    return _campagneJoinRequestHandlejoinrequestPost(body: body);
  }

  ///Accepts or denies a campagneJoinRequest with the calling user as dm.
  @POST(path: '/CampagneJoinRequest/handlejoinrequest', optionalBody: true)
  Future<chopper.Response> _campagneJoinRequestHandlejoinrequestPost({
    @Body() required HandleJoinRequestDto? body,
  });

  ///Returns a list of campagneJoinRequests for a campagne this user is the dm of.
  ///@param campagneId campagneId
  Future<chopper.Response<List<JoinRequestForCampagneDto>>>
  campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet({
    required String? campagneId,
  }) {
    generatedMapping.putIfAbsent(
      JoinRequestForCampagneDto,
      () => JoinRequestForCampagneDto.fromJsonFactory,
    );

    return _campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet(
      campagneId: campagneId,
    );
  }

  ///Returns a list of campagneJoinRequests for a campagne this user is the dm of.
  ///@param campagneId campagneId
  @GET(path: '/CampagneJoinRequest/getcampagneJoinRequests/{campagneId}')
  Future<chopper.Response<List<JoinRequestForCampagneDto>>>
  _campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet({
    @Path('campagneId') required String? campagneId,
  });

  ///
  ///@param campagneid
  Future<chopper.Response<String>> imageGenerateimageCampagneidPost({
    required String? campagneid,
    required String? body,
  }) {
    return _imageGenerateimageCampagneidPost(
      campagneid: campagneid,
      body: body,
    );
  }

  ///
  ///@param campagneid
  @POST(path: '/Image/generateimage/{campagneid}', optionalBody: true)
  Future<chopper.Response<String>> _imageGenerateimageCampagneidPost({
    @Path('campagneid') required String? campagneid,
    @Body() required String? body,
  });

  ///Streams an image upload directly to the server.
  ///@param campagneId
  Future<chopper.Response<String>> imageStreamimageuploadPost({
    required String? campagneId,
    List<int>? image,
  }) {
    return _imageStreamimageuploadPost(campagneId: campagneId, image: image);
  }

  ///Streams an image upload directly to the server.
  ///@param campagneId
  @POST(path: '/Image/streamimageupload', optionalBody: true)
  @Multipart()
  Future<chopper.Response<String>> _imageStreamimageuploadPost({
    @Query('campagneId') required String? campagneId,
    @PartFile() List<int>? image,
  });

  ///Returns all images (their metadata urls) for a specific campagne where the creator is the requesting user.
  ///@param campagneId The ID of the campagne to retrieve images for.
  Future<chopper.Response<List<ImageMetaData>>> imageGetimagesCampagneIdGet({
    required String? campagneId,
  }) {
    generatedMapping.putIfAbsent(
      ImageMetaData,
      () => ImageMetaData.fromJsonFactory,
    );

    return _imageGetimagesCampagneIdGet(campagneId: campagneId);
  }

  ///Returns all images (their metadata urls) for a specific campagne where the creator is the requesting user.
  ///@param campagneId The ID of the campagne to retrieve images for.
  @GET(path: '/Image/getimages/{campagneId}')
  Future<chopper.Response<List<ImageMetaData>>> _imageGetimagesCampagneIdGet({
    @Path('campagneId') required String? campagneId,
  });

  ///Returns a list of documents this user can see for a given campagne.
  ///@param campagneid The id of the desired campagne
  Future<chopper.Response<List<NoteDocumentDto>>>
  notesGetdocumentsCampagneidGet({required String? campagneid}) {
    generatedMapping.putIfAbsent(
      NoteDocumentDto,
      () => NoteDocumentDto.fromJsonFactory,
    );

    return _notesGetdocumentsCampagneidGet(campagneid: campagneid);
  }

  ///Returns a list of documents this user can see for a given campagne.
  ///@param campagneid The id of the desired campagne
  @GET(path: '/Notes/getdocuments/{campagneid}')
  Future<chopper.Response<List<NoteDocumentDto>>>
  _notesGetdocumentsCampagneidGet({
    @Path('campagneid') required String? campagneid,
  });

  ///Returns a single document.
  ///@param notedocumentid The id of the desired campagne
  Future<chopper.Response<NoteDocumentDto>> notesGetdocumentNotedocumentidGet({
    required String? notedocumentid,
  }) {
    generatedMapping.putIfAbsent(
      NoteDocumentDto,
      () => NoteDocumentDto.fromJsonFactory,
    );

    return _notesGetdocumentNotedocumentidGet(notedocumentid: notedocumentid);
  }

  ///Returns a single document.
  ///@param notedocumentid The id of the desired campagne
  @GET(path: '/Notes/getdocument/{notedocumentid}')
  Future<chopper.Response<NoteDocumentDto>> _notesGetdocumentNotedocumentidGet({
    @Path('notedocumentid') required String? notedocumentid,
  });

  ///Deletes a single document.
  ///@param notedocumentid The id of the desired campagne
  Future<chopper.Response<NoteDocumentDto>>
  notesDeletedocumentNotedocumentidDelete({required String? notedocumentid}) {
    generatedMapping.putIfAbsent(
      NoteDocumentDto,
      () => NoteDocumentDto.fromJsonFactory,
    );

    return _notesDeletedocumentNotedocumentidDelete(
      notedocumentid: notedocumentid,
    );
  }

  ///Deletes a single document.
  ///@param notedocumentid The id of the desired campagne
  @DELETE(path: '/Notes/deletedocument/{notedocumentid}')
  Future<chopper.Response<NoteDocumentDto>>
  _notesDeletedocumentNotedocumentidDelete({
    @Path('notedocumentid') required String? notedocumentid,
  });

  ///Creates a single document.
  Future<chopper.Response<NoteDocumentIdentifier>> notesCreatedocumentPost({
    required NoteDocumentDto? body,
  }) {
    generatedMapping.putIfAbsent(
      NoteDocumentIdentifier,
      () => NoteDocumentIdentifier.fromJsonFactory,
    );

    return _notesCreatedocumentPost(body: body);
  }

  ///Creates a single document.
  @POST(path: '/Notes/createdocument', optionalBody: true)
  Future<chopper.Response<NoteDocumentIdentifier>> _notesCreatedocumentPost({
    @Body() required NoteDocumentDto? body,
  });

  ///Creates a single text block for a given document.
  ///@param notedocumentid The document id where this block will be assigned
  Future<chopper.Response<TextBlock>> notesCreatetextblockNotedocumentidPost({
    required String? notedocumentid,
    required TextBlock? body,
  }) {
    generatedMapping.putIfAbsent(TextBlock, () => TextBlock.fromJsonFactory);

    return _notesCreatetextblockNotedocumentidPost(
      notedocumentid: notedocumentid,
      body: body,
    );
  }

  ///Creates a single text block for a given document.
  ///@param notedocumentid The document id where this block will be assigned
  @POST(path: '/Notes/createtextblock/{notedocumentid}', optionalBody: true)
  Future<chopper.Response<TextBlock>> _notesCreatetextblockNotedocumentidPost({
    @Path('notedocumentid') required String? notedocumentid,
    @Body() required TextBlock? body,
  });

  ///Creates a single image block for a given document.
  ///@param notedocumentid The document id where this block will be assigned
  Future<chopper.Response<ImageBlock>> notesCreateimageblockNotedocumentidPost({
    required String? notedocumentid,
    required ImageBlock? body,
  }) {
    generatedMapping.putIfAbsent(ImageBlock, () => ImageBlock.fromJsonFactory);

    return _notesCreateimageblockNotedocumentidPost(
      notedocumentid: notedocumentid,
      body: body,
    );
  }

  ///Creates a single image block for a given document.
  ///@param notedocumentid The document id where this block will be assigned
  @POST(path: '/Notes/createimageblock/{notedocumentid}', optionalBody: true)
  Future<chopper.Response<ImageBlock>>
  _notesCreateimageblockNotedocumentidPost({
    @Path('notedocumentid') required String? notedocumentid,
    @Body() required ImageBlock? body,
  });

  ///Updates a single text block for a given document.
  Future<chopper.Response> notesUpdatetextblockPut({required TextBlock? body}) {
    return _notesUpdatetextblockPut(body: body);
  }

  ///Updates a single text block for a given document.
  @PUT(path: '/Notes/updatetextblock', optionalBody: true)
  Future<chopper.Response> _notesUpdatetextblockPut({
    @Body() required TextBlock? body,
  });

  ///Updates a single image block for a given document.
  Future<chopper.Response> notesUpdateimageblockPut({
    required ImageBlock? body,
  }) {
    return _notesUpdateimageblockPut(body: body);
  }

  ///Updates a single image block for a given document.
  @PUT(path: '/Notes/updateimageblock', optionalBody: true)
  Future<chopper.Response> _notesUpdateimageblockPut({
    @Body() required ImageBlock? body,
  });

  ///Updates a document.
  Future<chopper.Response> notesUpdatenotePut({
    required NoteDocumentDto? body,
  }) {
    return _notesUpdatenotePut(body: body);
  }

  ///Updates a document.
  @PUT(path: '/Notes/updatenote', optionalBody: true)
  Future<chopper.Response> _notesUpdatenotePut({
    @Body() required NoteDocumentDto? body,
  });

  ///Deletes a single note block for a given document.
  ///@param Value
  Future<chopper.Response> notesDeleteblockDelete({String? $Value}) {
    return _notesDeleteblockDelete($Value: $Value);
  }

  ///Deletes a single note block for a given document.
  ///@param Value
  @DELETE(path: '/Notes/deleteblock')
  Future<chopper.Response> _notesDeleteblockDelete({
    @Query('Value') String? $Value,
  });

  ///Creates a new player character with the calling user as owner.
  Future<chopper.Response<PlayerCharacterIdentifier>>
  playerCharacterCreatecharacterPost({
    required PlayerCharacterCreateDto? body,
  }) {
    generatedMapping.putIfAbsent(
      PlayerCharacterIdentifier,
      () => PlayerCharacterIdentifier.fromJsonFactory,
    );

    return _playerCharacterCreatecharacterPost(body: body);
  }

  ///Creates a new player character with the calling user as owner.
  @POST(path: '/PlayerCharacter/createcharacter', optionalBody: true)
  Future<chopper.Response<PlayerCharacterIdentifier>>
  _playerCharacterCreatecharacterPost({
    @Body() required PlayerCharacterCreateDto? body,
  });

  ///Returns a list of player characters for the calling user.
  Future<chopper.Response<List<PlayerCharacter>>>
  playerCharacterGetplayercharactersGet() {
    generatedMapping.putIfAbsent(
      PlayerCharacter,
      () => PlayerCharacter.fromJsonFactory,
    );

    return _playerCharacterGetplayercharactersGet();
  }

  ///Returns a list of player characters for the calling user.
  @GET(path: '/PlayerCharacter/getplayercharacters')
  Future<chopper.Response<List<PlayerCharacter>>>
  _playerCharacterGetplayercharactersGet();

  ///Returns a single playerCharacter.
  ///@param playercharacterid The id of the desired playerCharacter
  Future<chopper.Response<PlayerCharacter>>
  playerCharacterGetplayercharacterPlayercharacteridGet({
    required String? playercharacterid,
  }) {
    generatedMapping.putIfAbsent(
      PlayerCharacter,
      () => PlayerCharacter.fromJsonFactory,
    );

    return _playerCharacterGetplayercharacterPlayercharacteridGet(
      playercharacterid: playercharacterid,
    );
  }

  ///Returns a single playerCharacter.
  ///@param playercharacterid The id of the desired playerCharacter
  @GET(path: '/PlayerCharacter/getplayercharacter/{playercharacterid}')
  Future<chopper.Response<PlayerCharacter>>
  _playerCharacterGetplayercharacterPlayercharacteridGet({
    @Path('playercharacterid') required String? playercharacterid,
  });

  ///Returns a list of player characters for a given campagne.
  ///@param Value
  Future<chopper.Response<List<PlayerCharacter>>>
  playerCharacterGetplayercharactersincampagneGet({String? $Value}) {
    generatedMapping.putIfAbsent(
      PlayerCharacter,
      () => PlayerCharacter.fromJsonFactory,
    );

    return _playerCharacterGetplayercharactersincampagneGet($Value: $Value);
  }

  ///Returns a list of player characters for a given campagne.
  ///@param Value
  @GET(path: '/PlayerCharacter/getplayercharactersincampagne')
  Future<chopper.Response<List<PlayerCharacter>>>
  _playerCharacterGetplayercharactersincampagneGet({
    @Query('Value') String? $Value,
  });

  ///Returns a list of all users assigned to the campagne with meta information.
  ///@param Value
  Future<chopper.Response<List<NoteDocumentPlayerDescriptorDto>>>
  playerCharacterGetnoteDocumentPlayerDescriptorDtosincampagneGet({
    String? $Value,
  }) {
    generatedMapping.putIfAbsent(
      NoteDocumentPlayerDescriptorDto,
      () => NoteDocumentPlayerDescriptorDto.fromJsonFactory,
    );

    return _playerCharacterGetnoteDocumentPlayerDescriptorDtosincampagneGet(
      $Value: $Value,
    );
  }

  ///Returns a list of all users assigned to the campagne with meta information.
  ///@param Value
  @GET(path: '/PlayerCharacter/getnoteDocumentPlayerDescriptorDtosincampagne')
  Future<chopper.Response<List<NoteDocumentPlayerDescriptorDto>>>
  _playerCharacterGetnoteDocumentPlayerDescriptorDtosincampagneGet({
    @Query('Value') String? $Value,
  });

  ///Returns the minimal app version supported by this api.
  Future<chopper.Response<String>> publicGetminimalversionGet() {
    return _publicGetminimalversionGet();
  }

  ///Returns the minimal app version supported by this api.
  @GET(path: '/Public/getminimalversion')
  Future<chopper.Response<String>> _publicGetminimalversionGet();

  ///
  ///@param uuid
  ///@param apikey
  Future<chopper.Response> publicGetimageUuidApikeyGet({
    required String? uuid,
    required String? apikey,
  }) {
    return _publicGetimageUuidApikeyGet(uuid: uuid, apikey: apikey);
  }

  ///
  ///@param uuid
  ///@param apikey
  @GET(path: '/Public/getimage/{uuid}/{apikey}')
  Future<chopper.Response> _publicGetimageUuidApikeyGet({
    @Path('uuid') required String? uuid,
    @Path('apikey') required String? apikey,
  });

  ///This method generates a new encryptionChallenge and stores it in the db.
  ///Use this method as first start point for a register operation.
  Future<chopper.Response<String>> registerCreateencryptionchallengePost({
    required String? body,
  }) {
    return _registerCreateencryptionchallengePost(body: body);
  }

  ///This method generates a new encryptionChallenge and stores it in the db.
  ///Use this method as first start point for a register operation.
  @POST(path: '/Register/createencryptionchallenge', optionalBody: true)
  Future<chopper.Response<String>> _registerCreateencryptionchallengePost({
    @Body() required String? body,
  });

  ///Creates a new user with "username and password" sign in.
  Future<chopper.Response<String>> registerRegisterPost({
    required String? body,
  }) {
    return _registerRegisterPost(body: body);
  }

  ///Creates a new user with "username and password" sign in.
  @POST(path: '/Register/register', optionalBody: true)
  Future<chopper.Response<String>> _registerRegisterPost({
    @Body() required String? body,
  });

  ///Creates a new user for an open sign OpenSignInProviderRegisterRequest.
  Future<chopper.Response<String>> registerRegisterwithapikeyPost({
    required RegisterWithApiKeyDto? body,
  }) {
    return _registerRegisterwithapikeyPost(body: body);
  }

  ///Creates a new user for an open sign OpenSignInProviderRegisterRequest.
  @POST(path: '/Register/registerwithapikey', optionalBody: true)
  Future<chopper.Response<String>> _registerRegisterwithapikeyPost({
    @Body() required RegisterWithApiKeyDto? body,
  });

  ///Lets the user verify their email.
  ///@param useridbase64 The base64 encoded userid
  ///@param signaturebase64 The server generated signature for the userid
  Future<chopper.Response<String>>
  registerVerifyemailUseridbase64Signaturebase64Get({
    required String? useridbase64,
    required String? signaturebase64,
  }) {
    return _registerVerifyemailUseridbase64Signaturebase64Get(
      useridbase64: useridbase64,
      signaturebase64: signaturebase64,
    );
  }

  ///Lets the user verify their email.
  ///@param useridbase64 The base64 encoded userid
  ///@param signaturebase64 The server generated signature for the userid
  @GET(path: '/Register/verifyemail/{useridbase64}/{signaturebase64}')
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
  @GET(path: '/SignIn/testlogin')
  Future<chopper.Response<String>> _signInTestloginGet();

  ///Returns the encryption challenge for a given username.
  ///@param username The username of the desired encryption challenge
  Future<chopper.Response<String>>
  signInGetloginchallengeforusernameUsernamePost({
    required String? username,
    required EncryptedMessageWrapperDto? body,
  }) {
    return _signInGetloginchallengeforusernameUsernamePost(
      username: username,
      body: body,
    );
  }

  ///Returns the encryption challenge for a given username.
  ///@param username The username of the desired encryption challenge
  @POST(
    path: '/SignIn/getloginchallengeforusername/{username}',
    optionalBody: true,
  )
  Future<chopper.Response<String>>
  _signInGetloginchallengeforusernameUsernamePost({
    @Path('username') required String? username,
    @Body() required EncryptedMessageWrapperDto? body,
  });

  ///Performs the login with username and password.
  Future<chopper.Response<String>> signInLoginPost({
    required LoginWithUsernameAndPasswordDto? body,
  }) {
    return _signInLoginPost(body: body);
  }

  ///Performs the login with username and password.
  @POST(path: '/SignIn/login', optionalBody: true)
  Future<chopper.Response<String>> _signInLoginPost({
    @Body() required LoginWithUsernameAndPasswordDto? body,
  });

  ///
  Future<chopper.Response<String>> signInLoginwithapplePost({
    required AppleLoginDetails? body,
  }) {
    return _signInLoginwithapplePost(body: body);
  }

  ///
  @POST(path: '/SignIn/loginwithapple', optionalBody: true)
  Future<chopper.Response<String>> _signInLoginwithapplePost({
    @Body() required AppleLoginDetails? body,
  });

  ///
  Future<chopper.Response<String>> signInLoginwithgooglePost({
    required GoogleLoginDto? body,
  }) {
    return _signInLoginwithgooglePost(body: body);
  }

  ///
  @POST(path: '/SignIn/loginwithgoogle', optionalBody: true)
  Future<chopper.Response<String>> _signInLoginwithgooglePost({
    @Body() required GoogleLoginDto? body,
  });

  ///Requests an reset password email for the user.
  Future<chopper.Response<String>> signInRequestresetpasswordPost({
    required ResetPasswordRequestDto? body,
  }) {
    return _signInRequestresetpasswordPost(body: body);
  }

  ///Requests an reset password email for the user.
  @POST(path: '/SignIn/requestresetpassword', optionalBody: true)
  Future<chopper.Response<String>> _signInRequestresetpasswordPost({
    @Body() required ResetPasswordRequestDto? body,
  });

  ///Completes the password reset requests by providing the reset code from the email.
  Future<chopper.Response<String>> signInResetpasswordPost({
    required ResetPasswordDto? body,
  }) {
    return _signInResetpasswordPost(body: body);
  }

  ///Completes the password reset requests by providing the reset code from the email.
  @POST(path: '/SignIn/resetpassword', optionalBody: true)
  Future<chopper.Response<String>> _signInResetpasswordPost({
    @Body() required ResetPasswordDto? body,
  });
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
    chopper.Response response,
  ) async {
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
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
