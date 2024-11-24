import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';

class NavbarNewDesign extends StatelessWidget {
  const NavbarNewDesign(
      {super.key,
      required this.useTopSafePadding,
      required this.closeFunction,
      required this.titleWidget,
      required this.menuOpen,
      required this.backInsteadOfCloseIcon});

  final bool useTopSafePadding;
  final bool backInsteadOfCloseIcon;
  final Null Function()? closeFunction;
  final Widget titleWidget;
  final Null Function()? menuOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (useTopSafePadding)
          Container(
            height: MediaQuery.of(context).padding.top,
            color: darkColor,
          ),
        Container(
          height: 50,
          color: darkColor,
          child: Row(
            children: [
              Opacity(
                opacity: closeFunction == null ? 0 : 1,
                child: CustomButtonNewdesign(
                  variant: CustomButtonNewdesignVariant.FlatButton,
                  onPressed: closeFunction,
                  icon: CustomFaIcon(
                    icon: backInsteadOfCloseIcon
                        ? FontAwesomeIcons.chevronLeft
                        : FontAwesomeIcons.xmark,
                  ),
                ),
              ),
              Expanded(child: titleWidget),
              Opacity(
                opacity: menuOpen == null ? 0 : 1,
                child: CustomButtonNewdesign(
                  variant: CustomButtonNewdesignVariant.FlatButton,
                  onPressed: menuOpen,
                  icon: CustomFaIcon(icon: FontAwesomeIcons.bars),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
