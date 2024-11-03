import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

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
                  accentColor.withAlpha(100),
                  accentColor.withAlpha(130),
                  accentColor.withAlpha(180),
                  accentColor.withAlpha(215),
                  accentColor,
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
