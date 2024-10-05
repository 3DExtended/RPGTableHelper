import 'dart:developer';

import 'package:flutter/foundation.dart';

void debugLog(String message, String uuidErrorCode) {
  if (kDebugMode) {
    log('DEBUG: $message (Code: $uuidErrorCode)');
  }
}

void debugWarn(String message, String uuidErrorCode) {
  if (kDebugMode) {
    log('WARN: $message (Code: $uuidErrorCode)');
  }
}

void debugError(String message, String uuidErrorCode) {
  if (kDebugMode) {
    log('ERR: $message (Code: $uuidErrorCode)');
  }
}
