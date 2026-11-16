import 'package:flutter/widgets.dart';

/// Screens narrower than this on their short side are phones.
const double phoneShortestSideMax = 600;

extension PhoneLayout on BuildContext {
  /// True on phones in either orientation; false on every iPad.
  ///
  /// Unlike `isTablet` (aspect ratio), this does not count an iPad mini in
  /// landscape (1133 x 744) as a phone, so iPads keep their layout.
  bool get isPhone =>
      MediaQuery.sizeOf(this).shortestSide < phoneShortestSideMax;
}
