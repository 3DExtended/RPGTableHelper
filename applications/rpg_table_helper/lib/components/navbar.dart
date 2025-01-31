import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/constants.dart';

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
    return Column(
      children: [
        if (useTopSafePadding)
          Container(
            height: MediaQuery.of(context).padding.top,
            color: darkColor,
          ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50),
          child: Container(
            color: darkColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Opacity(
                    opacity: closeFunction == null ? 0 : 1,
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: closeFunction,
                      icon: CustomFaIcon(
                        icon: backInsteadOfCloseIcon
                            ? FontAwesomeIcons.chevronLeft
                            : FontAwesomeIcons.xmark,
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
                  child: CustomButton(
                    variant: CustomButtonVariant.FlatButton,
                    onPressed: menuOpen,
                    icon: CustomFaIcon(icon: FontAwesomeIcons.bars),
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
