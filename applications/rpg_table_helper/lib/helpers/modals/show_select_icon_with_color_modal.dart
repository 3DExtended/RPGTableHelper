// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:shadow_widget/shadow_widget.dart';

const List<Color> allIconColors = [
  Color.fromARGB(255, 244, 231, 54),
  Color.fromARGB(255, 54, 244, 238),
  Color.fromARGB(255, 142, 130, 253),
  Color.fromARGB(255, 76, 244, 54),
  Color.fromARGB(255, 235, 109, 100),
  Color(0xffff00ff)
];

Future<(String iconName, Color iconColor)?> showSelectIconWithColorModal(
    BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey,
    String? alreadySelectedIcoName,
    Color? alreadySelectedIconColor}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
          (String iconName, Color iconColor)>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return SelectIconWithColorModalContent(
          modalPadding: modalPadding,
          alreadySelectedIcoName: alreadySelectedIcoName,
          alreadySelectedIconColor: alreadySelectedIconColor,
        );
      });
}

class SelectIconWithColorModalContent extends StatefulWidget {
  const SelectIconWithColorModalContent({
    super.key,
    required this.modalPadding,
    this.alreadySelectedIcoName,
    this.alreadySelectedIconColor,
  });

  final double modalPadding;
  final Color? alreadySelectedIconColor;
  final String? alreadySelectedIcoName;

  @override
  State<SelectIconWithColorModalContent> createState() =>
      _SelectIconWithColorModalContentState();
}

class _SelectIconWithColorModalContentState
    extends State<SelectIconWithColorModalContent> {
  int alreadySeenItems = 0;

  String? selectedIconName;
  Color? selectedIconColor;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedIconColor = widget.alreadySelectedIconColor;
        selectedIconName = widget.alreadySelectedIcoName;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: ShadowWidget(
            offset: Offset(-4, 4),
            blurRadius: 5,
            child: Container(
              color: bgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  NavbarNewDesign(
                    backInsteadOfCloseIcon: false,
                    closeFunction: () {
                      navigatorKey.currentState!.pop(null);
                    },
                    menuOpen: null,
                    useTopSafePadding: false,
                    titleWidget: Text(
                      "Icon auswählen", // TODO localize/ switch text between add and edit
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: textColor, fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          // selection of color and icon
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "Select a color:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 24,
                                        ),
                                  ),
                                  // show colors:
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: allIconColors
                                        .map((color) => CustomButtonNewdesign(
                                              isSubbutton: false,
                                              variant: selectedIconColor ==
                                                      color
                                                  ? CustomButtonNewdesignVariant
                                                      .DarkButton
                                                  : CustomButtonNewdesignVariant
                                                      .FlatButton,
                                              onPressed: () {
                                                setState(() {
                                                  selectedIconColor = color;
                                                });
                                              },
                                              icon: Container(
                                                width: 32,
                                                height: 32,
                                                color: color,
                                              ),
                                            ))
                                        .toList(),
                                  ),

                                  Text(
                                    "Select an icon:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 24,
                                        ),
                                  ),

                                  // show icons:
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: allIconNames
                                        .map((name) => CustomButtonNewdesign(
                                              isSubbutton: false,
                                              variant: selectedIconName == name
                                                  ? CustomButtonNewdesignVariant
                                                      .DarkButton
                                                  : CustomButtonNewdesignVariant
                                                      .Default,
                                              onPressed: () {
                                                setState(() {
                                                  selectedIconName = name;
                                                });
                                              },
                                              icon: getIconForIdentifier(
                                                name: name,
                                                color: selectedIconName == name
                                                    ? bgColor
                                                    : darkTextColor,
                                                size: 32,
                                              ).$2,
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Vorschau
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Vorschau:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 24,
                                        ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  CustomItemCard(
                                    scalarOverride: 1,
                                    title: "Item", // TODO localize
                                    description:
                                        "Some items description", // TODO localize

                                    categoryIconColor: selectedIconColor,
                                    categoryIconName: selectedIconName,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                    child: Row(
                      children: [
                        const Spacer(),
                        CustomButtonNewdesign(
                          label: "Speichern", // TODO localize
                          onPressed: () {
                            navigatorKey.currentState!.pop(
                                selectedIconName == null ||
                                        selectedIconColor == null
                                    ? null
                                    : (selectedIconName!, selectedIconColor!));
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
