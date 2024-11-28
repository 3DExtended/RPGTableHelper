// Generated code

part of 'swagger.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Swagger extends Swagger {
  _$Swagger([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Swagger;

  @override
  Future<Response<CampagneIdentifier>> _campagneCreatecampagnePost(
      {required CampagneCreateDto? body}) {
    final Uri $url = Uri.parse('/Campagne/createcampagne');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CampagneIdentifier, CampagneIdentifier>($request);
  }

  @override
  Future<Response<List<Campagne>>> _campagneGetcampagnesGet() {
    final Uri $url = Uri.parse('/Campagne/getcampagnes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Campagne>, Campagne>($request);
  }

  @override
  Future<Response<Campagne>> _campagneGetcampagneCampagneidGet(
      {required String? campagneid}) {
    final Uri $url = Uri.parse('/Campagne/getcampagne/${campagneid}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Campagne, Campagne>($request);
  }

  @override
  Future<Response<CampagneJoinRequestIdentifier>>
      _campagneJoinRequestCreatecampagneJoinRequestPost(
          {required CampagneJoinRequestCreateDto? body}) {
    final Uri $url =
        Uri.parse('/CampagneJoinRequest/createcampagneJoinRequest');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CampagneJoinRequestIdentifier,
        CampagneJoinRequestIdentifier>($request);
  }

  @override
  Future<Response<dynamic>> _campagneJoinRequestHandlejoinrequestPost(
      {required HandleJoinRequestDto? body}) {
    final Uri $url = Uri.parse('/CampagneJoinRequest/handlejoinrequest');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<JoinRequestForCampagneDto>>>
      _campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet(
          {required String? campagneId}) {
    final Uri $url =
        Uri.parse('/CampagneJoinRequest/getcampagneJoinRequests/${campagneId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<JoinRequestForCampagneDto>,
        JoinRequestForCampagneDto>($request);
  }

  @override
  Future<Response<String>> _imageGenerateimageCampagneidPost({
    required String? campagneid,
    required String? body,
  }) {
    final Uri $url = Uri.parse('/Image/generateimage/${campagneid}');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _imageStreamimageuploadPost({String? campagneId}) {
    final Uri $url = Uri.parse('/Image/streamimageupload');
    final Map<String, dynamic> $params = <String, dynamic>{
      'campagneId': campagneId
    };
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<PlayerCharacterIdentifier>>
      _playerCharacterCreatecharacterPost(
          {required PlayerCharacterCreateDto? body}) {
    final Uri $url = Uri.parse('/PlayerCharacter/createcharacter');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client
        .send<PlayerCharacterIdentifier, PlayerCharacterIdentifier>($request);
  }

  @override
  Future<Response<List<PlayerCharacter>>>
      _playerCharacterGetplayercharactersGet() {
    final Uri $url = Uri.parse('/PlayerCharacter/getplayercharacters');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<PlayerCharacter>, PlayerCharacter>($request);
  }

  @override
  Future<Response<PlayerCharacter>>
      _playerCharacterGetplayercharacterPlayercharacteridGet(
          {required String? playercharacterid}) {
    final Uri $url =
        Uri.parse('/PlayerCharacter/getplayercharacter/${playercharacterid}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<PlayerCharacter, PlayerCharacter>($request);
  }

  @override
  Future<Response<List<PlayerCharacter>>>
      _playerCharacterGetplayercharactersincampagneGet({String? $Value}) {
    final Uri $url =
        Uri.parse('/PlayerCharacter/getplayercharactersincampagne');
    final Map<String, dynamic> $params = <String, dynamic>{'Value': $Value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<PlayerCharacter>, PlayerCharacter>($request);
  }

  @override
  Future<Response<String>> _publicGetminimalversionGet() {
    final Uri $url = Uri.parse('/Public/getminimalversion');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>> _publicCreateimagePost({String? prompt}) {
    final Uri $url = Uri.parse('/Public/createimage');
    final Map<String, dynamic> $params = <String, dynamic>{'prompt': prompt};
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _publicGetimageUuidApikeyGet({
    required String? uuid,
    required String? apikey,
  }) {
    final Uri $url = Uri.parse('/Public/getimage/${uuid}/${apikey}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<String>> _registerCreateencryptionchallengePost(
      {required String? body}) {
    final Uri $url = Uri.parse('/Register/createencryptionchallenge');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerRegisterPost({required String? body}) {
    final Uri $url = Uri.parse('/Register/register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerRegisterwithapikeyPost(
      {required RegisterWithApiKeyDto? body}) {
    final Uri $url = Uri.parse('/Register/registerwithapikey');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerVerifyemailUseridbase64Signaturebase64Get({
    required String? useridbase64,
    required String? signaturebase64,
  }) {
    final Uri $url =
        Uri.parse('/Register/verifyemail/${useridbase64}/${signaturebase64}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInTestloginGet() {
    final Uri $url = Uri.parse('/SignIn/testlogin');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInGetloginchallengeforusernameUsernamePost({
    required String? username,
    required EncryptedMessageWrapperDto? body,
  }) {
    final Uri $url =
        Uri.parse('/SignIn/getloginchallengeforusername/${username}');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginPost(
      {required LoginWithUsernameAndPasswordDto? body}) {
    final Uri $url = Uri.parse('/SignIn/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginwithapplePost(
      {required AppleLoginDetails? body}) {
    final Uri $url = Uri.parse('/SignIn/loginwithapple');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginwithgooglePost(
      {required GoogleLoginDto? body}) {
    final Uri $url = Uri.parse('/SignIn/loginwithgoogle');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInRequestresetpasswordPost(
      {required ResetPasswordRequestDto? body}) {
    final Uri $url = Uri.parse('/SignIn/requestresetpassword');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInResetpasswordPost(
      {required ResetPasswordDto? body}) {
    final Uri $url = Uri.parse('/SignIn/resetpassword');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<String, String>($request);
  }
}
