import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rpg_table_helper/helpers/debugger.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';

part 'humanreadable_response.g.dart';

@JsonSerializable(
    explicitToJson: true, createToJson: true, createFactory: false)
abstract class HRResponseBase {
  Map<String, dynamic> toJson() => _$HRResponseBaseToJson(this);

  Future<void> possiblyHandleError(BuildContext context,
      {List<int>? allowedStatusCodes}) async {
    if (isSuccessful) {
      return;
    }

    if (statusCode != null &&
        allowedStatusCodes != null &&
        allowedStatusCodes.contains(statusCode)) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // TODO think about telemetry
    //  var telemetryService = DependencyProvider.of(context).telemetryService;
    //  telemetryService.trackError(
    //    severity: Severity.error,
    //    error: jsonEncode(toJson()),
    //  );
    //  await telemetryService.flush();

    if (!context.mounted) {
      return;
    }

    await showGenericErrorModal(this, context);

    if (customOnErrorHandler != null) {
      await customOnErrorHandler!(this);
    }
  }

  final bool isSuccessful;
  final String? errorCode;
  final int? statusCode;
  final String? humanReadableError;
  final String? errorFromServer;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Exception? caughtException;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Future<void> Function(HRResponseBase response)? customOnErrorHandler;

  const HRResponseBase({
    required this.isSuccessful,
    required this.errorCode,
    required this.statusCode,
    required this.humanReadableError,
    required this.errorFromServer,
    this.customOnErrorHandler,
    this.caughtException,
  });
}

class HRResponse<T> extends HRResponseBase {
  final T? result;

  static HRResponse<T> empty<T>({
    required String errorCode,
    required String humanReadableError,
  }) =>
      HRResponse<T>(
        result: null,
        errorFromServer: null,
        isSuccessful: false,
        errorCode: errorCode,
        humanReadableError: humanReadableError,
        caughtException: null,
        customOnErrorHandler: null,
        statusCode: null,
      );

  static HRResponse<T> fromResult<T>(T result, {int? statusCode}) =>
      HRResponse<T>(
        errorFromServer: null,
        result: result,
        isSuccessful: true,
        errorCode: null,
        humanReadableError: null,
        customOnErrorHandler: null,
        caughtException: null,
        statusCode: statusCode,
      );

  static Future<HRResponse<T>> fromFuture<T>(
    Future<T?> future,
    String humanReadableError,
    String errorCode, {
    Future<void> Function(HRResponseBase)? customOnErrorHandler,
  }) async {
    try {
      var result = await future;
      if (result == null) {
        return error<T>(
          humanReadableError,
          errorCode,
          customOnErrorHandler: customOnErrorHandler,
        );
      } else {
        return fromResult<T>(result, statusCode: null);
      }
    } on Exception catch (e) {
      return error<T>(
        humanReadableError,
        errorCode,
        caughtException: e,
        customOnErrorHandler: customOnErrorHandler,
      );
    }
  }

  static Future<HRResponse<T>> fromApiFuture<T>(
    Future<Response<T>> future,
    String humanReadableError,
    String errorCode, {
    Future<void> Function(HRResponseBase)? customOnErrorHandler,
  }) async {
    try {
      var result = await future;
      if (!result.isSuccessful) {
        return error<T>(
          humanReadableError,
          errorCode,
          errorFromServer: result.bodyString,
          customOnErrorHandler: customOnErrorHandler,
          statusCode: result.statusCode,
        );
      } else {
        return fromResult<T>(result.body as T, statusCode: result.statusCode);
      }
    } on Exception catch (e) {
      return error<T>(
        humanReadableError,
        errorCode,
        caughtException: e,
        customOnErrorHandler: customOnErrorHandler,
      );
    }
  }

  static HRResponse<T> error<T>(
    String humanReadableError,
    String errorCode, {
    String? errorFromServer,
    Exception? caughtException,
    Future<void> Function(HRResponseBase)? customOnErrorHandler,
    int? statusCode,
  }) {
    debugLog(humanReadableError, errorCode);

    return HRResponse<T>(
        result: null,
        isSuccessful: false,
        errorCode: errorCode,
        errorFromServer: errorFromServer,
        humanReadableError: humanReadableError,
        caughtException: caughtException,
        customOnErrorHandler: customOnErrorHandler,
        statusCode: statusCode);
  }

  HRResponse(
      {required this.result,
      required super.isSuccessful,
      required super.errorCode,
      required super.humanReadableError,
      required super.caughtException,
      required super.customOnErrorHandler,
      required super.statusCode,
      required super.errorFromServer})
      : super();

  HRResponse<O> asT<O>() {
    if (isSuccessful) {
      throw Exception('Could not convert to T');
    }
    return HRResponse<O>(
        errorFromServer: errorFromServer,
        caughtException: caughtException,
        isSuccessful: false,
        customOnErrorHandler: customOnErrorHandler,
        errorCode: errorCode,
        humanReadableError: humanReadableError,
        statusCode: statusCode,
        result: null);
  }
}
