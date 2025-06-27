import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    required this.useTopSafePadding,
    required this.closeFunction,
    required this.titleWidget,
    required this.backInsteadOfCloseIcon,
    required this.menuOpen,
    this.subTitle,
  });

  final bool useTopSafePadding;
  final bool backInsteadOfCloseIcon;
  final VoidCallback? closeFunction;
  final Widget titleWidget;
  final Widget? subTitle;
  final VoidCallback? menuOpen;

  @override
  Widget build(BuildContext context) {
    var backgroundColor =
        CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.light
            ? CustomThemeProvider.of(context).theme.darkColor
            : CustomThemeProvider.of(context).theme.bgColor.darker(0.4);

    var textColor = CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? CustomThemeProvider.of(context).theme.textColor
        : CustomThemeProvider.of(context).theme.darkTextColor;

    return Column(
      children: [
        if (useTopSafePadding)
          Container(
            height: MediaQuery.of(context).padding.top,
            color: backgroundColor,
          ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50),
          child: Container(
            color: backgroundColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Opacity(
                    opacity: closeFunction == null ? 0 : 1,
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: closeFunction,
                      icon: CustomFaIcon(
                        size: 20,
                        icon: backInsteadOfCloseIcon
                            ? FontAwesomeIcons.chevronLeft
                            : FontAwesomeIcons.xmark,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 9.0),
                  child: Column(
                    children: [
                      titleWidget,
                      if (subTitle != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: subTitle!,
                        ),
                    ],
                  ),
                )),
                Opacity(
                  opacity: menuOpen == null ? 0 : 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: menuOpen,
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.gears,
                        size: 20,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
