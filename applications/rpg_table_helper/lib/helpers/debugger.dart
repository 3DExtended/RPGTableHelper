import 'package:flutter/foundation.dart';

void debugLog(String message, String uuidErrorCode) {
  if (kDebugMode) {
    print('DEBUG: $message (Code: $uuidErrorCode)');
  }
}

void debugWarn(String message, String uuidErrorCode) {
  if (kDebugMode) {
    print('WARN: $message (Code: $uuidErrorCode)');
  }
}

void debugError(String message, String uuidErrorCode) {
  if (kDebugMode) {
    print('ERR: $message (Code: $uuidErrorCode)');
  }
}
