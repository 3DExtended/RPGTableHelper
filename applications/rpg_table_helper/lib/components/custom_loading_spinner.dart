import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

const loadingSpinnerAlphaValues = [100, 130, 180, 215, 255];

class CustomLoadingSpinner extends StatelessWidget {
  const CustomLoadingSpinner({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var isMocked = DependencyProvider.of(context).isMocked;
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: isMocked
            ? Container()
            : LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,

                /// Required, The loading type of the widget
                colors: [
                  ...loadingSpinnerAlphaValues.map((alpha) =>
                      CustomThemeProvider.of(context)
                          .theme
                          .accentColor
                          .withAlpha(alpha)),
                ],

                /// Optional, The color collections
                strokeWidth: 1,

                /// Optional, The stroke of the line, only applicable to widget which contains line
                backgroundColor: null,
              ),
      ),
    );
  }
}
