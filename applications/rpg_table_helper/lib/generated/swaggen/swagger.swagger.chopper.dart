// dart format width=80
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
  Future<Response<CreateApiKeyResponse>> _apiApiKeysPost({
    required CreateApiKeyRequestDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          '''Creates a new API key with the given scopes. Only callable with a normal login (JWT): an API key can
never create, list or revoke keys.''',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiKeys"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/ApiKeys');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CreateApiKeyResponse, CreateApiKeyResponse>($request);
  }

  @override
  Future<Response<List<ApiKeyDto>>> _apiApiKeysGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Gets all API keys for the current user.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiKeys"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/ApiKeys');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<ApiKeyDto>, ApiKeyDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiApiKeysIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Revokes an API key.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiKeys"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/ApiKeys/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<CampagneIdentifier>> _campagneCreatecampagnePost({
    required CampagneCreateDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Creates a new campagne with the calling user as dm.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Campagne"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Campagne/createcampagne');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CampagneIdentifier, CampagneIdentifier>($request);
  }

  @override
  Future<Response<List<Campagne>>> _campagneGetcampagnesGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Returns a list of campagnes this user is the dm of.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Campagne"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Campagne/getcampagnes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<Campagne>, Campagne>($request);
  }

  @override
  Future<Response<Campagne>> _campagneGetcampagneCampagneidGet({
    required String? campagneid,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the dm or a player in this campagne',
      summary: 'Returns a single of campagne.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Campagne"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Campagne/getcampagne/${campagneid}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Campagne, Campagne>($request);
  }

  @override
  Future<Response<CampagneJoinRequestIdentifier>>
  _campagneJoinRequestCreatecampagneJoinRequestPost({
    required CampagneJoinRequestCreateDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Creates a new campagneJoinRequest with the calling user as dm.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CampagneJoinRequest"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/CampagneJoinRequest/createcampagneJoinRequest',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<CampagneJoinRequestIdentifier, CampagneJoinRequestIdentifier>(
          $request,
        );
  }

  @override
  Future<Response<dynamic>> _campagneJoinRequestHandlejoinrequestPost({
    required HandleJoinRequestDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Accepts or denies a campagneJoinRequest with the calling user as dm.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CampagneJoinRequest"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/CampagneJoinRequest/handlejoinrequest');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<JoinRequestForCampagneDto>>>
  _campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet({
    required String? campagneId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Returns a list of campagneJoinRequests for a campagne this user is the dm of.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CampagneJoinRequest"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/CampagneJoinRequest/getcampagneJoinRequests/${campagneId}',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client
        .send<List<JoinRequestForCampagneDto>, JoinRequestForCampagneDto>(
          $request,
        );
  }

  @override
  Future<Response<String>> _imageGenerateimageCampagneidPost({
    required String? campagneid,
    required String? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Image"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Image/generateimage/${campagneid}');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _imageStreamimageuploadPost({
    required String? campagneId,
    List<int>? image,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Streams an image upload directly to the server.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Image"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Image/streamimageupload');
    final Map<String, dynamic> $params = <String, dynamic>{
      'campagneId': campagneId,
    };
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<int>?>('image', image),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<List<ImageMetaData>>> _imageGetimagesCampagneIdGet({
    required String? campagneId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Returns all images (their metadata urls) for a specific campagne where the creator is the requesting user.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Image"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Image/getimages/${campagneId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<ImageMetaData>, ImageMetaData>($request);
  }

  @override
  Future<Response<List<NoteDocumentDto>>> _notesGetdocumentsCampagneidGet({
    required String? campagneid,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be within the correct campagne',
      summary:
          'Returns a list of documents this user can see for a given campagne.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/getdocuments/${campagneid}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<NoteDocumentDto>, NoteDocumentDto>($request);
  }

  @override
  Future<Response<NoteDocumentDto>> _notesGetdocumentNotedocumentidGet({
    required String? notedocumentid,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'You must be within the correct campagne and the document has to be your own or shared with you',
      summary: 'Returns a single document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/getdocument/${notedocumentid}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<NoteDocumentDto, NoteDocumentDto>($request);
  }

  @override
  Future<Response<NoteDocumentDto>> _notesDeletedocumentNotedocumentidDelete({
    required String? notedocumentid,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'You must be within the correct campagne and the document has to be your own',
      summary: 'Deletes a single document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/deletedocument/${notedocumentid}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<NoteDocumentDto, NoteDocumentDto>($request);
  }

  @override
  Future<Response<NoteDocumentIdentifier>> _notesCreatedocumentPost({
    required NoteDocumentDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be within the correct campagne',
      summary: 'Creates a single document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/createdocument');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<NoteDocumentIdentifier, NoteDocumentIdentifier>(
      $request,
    );
  }

  @override
  Future<Response<TextBlock>> _notesCreatetextblockNotedocumentidPost({
    required String? notedocumentid,
    required TextBlock? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Creates a single text block for a given document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/createtextblock/${notedocumentid}');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TextBlock, TextBlock>($request);
  }

  @override
  Future<Response<ImageBlock>> _notesCreateimageblockNotedocumentidPost({
    required String? notedocumentid,
    required ImageBlock? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Creates a single image block for a given document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/createimageblock/${notedocumentid}');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ImageBlock, ImageBlock>($request);
  }

  @override
  Future<Response<dynamic>> _notesUpdatetextblockPut({
    required TextBlock? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Updates a single text block for a given document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/updatetextblock');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _notesUpdateimageblockPut({
    required ImageBlock? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Updates a single image block for a given document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/updateimageblock');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _notesUpdatenotePut({
    required NoteDocumentDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Updates a document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/updatenote');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _notesDeleteblockDelete({
    String? value,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of the document',
      summary: 'Deletes a single note block for a given document.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notes"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Notes/deleteblock');
    final Map<String, dynamic> $params = <String, dynamic>{'Value': value};
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PlayerCharacterIdentifier>>
  _playerCharacterCreatecharacterPost({
    required PlayerCharacterCreateDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Creates a new player character with the calling user as owner.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["PlayerCharacter"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/PlayerCharacter/createcharacter');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<PlayerCharacterIdentifier, PlayerCharacterIdentifier>(
      $request,
    );
  }

  @override
  Future<Response<List<PlayerCharacter>>>
  _playerCharacterGetplayercharactersGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Returns a list of player characters for the calling user.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["PlayerCharacter"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/PlayerCharacter/getplayercharacters');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<PlayerCharacter>, PlayerCharacter>($request);
  }

  @override
  Future<Response<PlayerCharacter>>
  _playerCharacterGetplayercharacterPlayercharacteridGet({
    required String? playercharacterid,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'You must be the owner of this playerCharacter',
      summary: 'Returns a single playerCharacter.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["PlayerCharacter"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/PlayerCharacter/getplayercharacter/${playercharacterid}',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<PlayerCharacter, PlayerCharacter>($request);
  }

  @override
  Future<Response<List<PlayerCharacter>>>
  _playerCharacterGetplayercharactersincampagneGet({
    String? value,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Please note that only the dm is allowed to retrieve the rpg character configs of the players. if you are not the dm, those configs will be empty!',
      summary: 'Returns a list of player characters for a given campagne.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["PlayerCharacter"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/PlayerCharacter/getplayercharactersincampagne',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'Value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<PlayerCharacter>, PlayerCharacter>($request);
  }

  @override
  Future<Response<List<NoteDocumentPlayerDescriptorDto>>>
  _playerCharacterGetnoteDocumentPlayerDescriptorDtosincampagneGet({
    String? value,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Returns a list of all users assigned to the campagne with meta information.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["PlayerCharacter"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/PlayerCharacter/getnoteDocumentPlayerDescriptorDtosincampagne',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'Value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      List<NoteDocumentPlayerDescriptorDto>,
      NoteDocumentPlayerDescriptorDto
    >($request);
  }

  @override
  Future<Response<String>> _publicGetminimalversionGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Returns the minimal app version supported by this api.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Public/getminimalversion');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<BackendCapabilitiesDto>> _publicCapabilitiesGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Advertises the optional features this backend supports so newer and older frontends/backends stay compatible. Purely additive; an older backend without this endpoint is treated by the client as "baseline capabilities only".',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Public/capabilities');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<BackendCapabilitiesDto, BackendCapabilitiesDto>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _publicGetimageUuidApikeyGet({
    required String? uuid,
    required String? apikey,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Public"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Public/getimage/${uuid}/${apikey}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<String>> _registerCreateencryptionchallengePost({
    required String? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Additionally, it uses rsa encryption to comunicate: the client has to provide a public pem
certificate encrypted with the public pem of this server and receives the encryption challenge
RSA encrypted with the provided public cert.
This way, no man in the middle can pretend to be the server as each client has a copy of the public cert of the server.''',
      summary:
          '''This method generates a new encryptionChallenge and stores it in the db.
Use this method as first start point for a register operation.''',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Register"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Register/createencryptionchallenge');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerRegisterPost({
    required String? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''In order to signup the provided body must be RSA encrypted with
the public certificate of this server. The dto must be of type
RPGTableHelper.WebApi.Dtos.RegisterWithUsernamePasswordDto.''',
      summary: 'Creates a new user with "username and password" sign in.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Register"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Register/register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerRegisterwithapikeyPost({
    required RegisterWithApiKeyDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Creates a new user for an open sign OpenSignInProviderRegisterRequest.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Register"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/Register/registerwithapikey');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _registerVerifyemailUseridbase64Signaturebase64Get({
    required String? useridbase64,
    required String? signaturebase64,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'This link is send via email to the user after registration (and only if the user used username and password login).',
      summary: 'Lets the user verify their email.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Register"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/Register/verifyemail/${useridbase64}/${signaturebase64}',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInTestloginGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'This method returns "Welcome" when the provided JWT is valid.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/testlogin');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInGetloginchallengeforusernameUsernamePost({
    required String? username,
    required EncryptedMessageWrapperDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Please note that the client has to provide an RSA public
key in order to receive the encrypted challenge dictionary.''',
      summary: 'Returns the encryption challenge for a given username.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/SignIn/getloginchallengeforusername/${username}',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginPost({
    required LoginWithUsernameAndPasswordDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Performs the login with username and password.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginwithapplePost({
    required AppleLoginDetails? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/loginwithapple');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginwithgooglePost({
    required GoogleLoginDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/loginwithgoogle');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInRequestresetpasswordPost({
    required ResetPasswordRequestDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Requests an reset password email for the user.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/requestresetpassword');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInResetpasswordPost({
    required ResetPasswordDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Completes the password reset requests by providing the reset code from the email.',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: ["SignIn"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/SignIn/resetpassword');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }
}
