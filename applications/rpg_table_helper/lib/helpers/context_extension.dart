import 'package:flutter/widgets.dart';

extension ContextExt on BuildContext {
  bool get isTablet {
    bool isTablet;
    double ratio =
        MediaQuery.of(this).size.width / MediaQuery.of(this).size.height;
    if ((ratio >= 0.74) && (ratio < 1.5)) {
      isTablet = true;
    } else {
      isTablet = false;
    }
    return isTablet;
  }
}
