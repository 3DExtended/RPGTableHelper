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
  Future<Response<String>> _registerRegisterchallengePost(
      {required String? body}) {
    final Uri $url = Uri.parse('/Register/registerchallenge');
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
  Future<Response<String>> _registerGetloginchallengeforusernameUsernamePost({
    required String? username,
    required EncryptedMessageWrapperDto? body,
  }) {
    final Uri $url =
        Uri.parse('/Register/getloginchallengeforusername/${username}');
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
      {required RegisterDto? body}) {
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
  Future<Response<String>> _signInGetminimalversionGet() {
    final Uri $url = Uri.parse('/SignIn/getminimalversion');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> _signInLoginPost({required LoginDto? body}) {
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
      {required AppleLoginDto? body}) {
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
