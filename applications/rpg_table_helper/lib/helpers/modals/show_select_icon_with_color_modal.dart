// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_item_card.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

const List<Color> allIconColors = [
  // -----
  Color.fromARGB(255, 249, 246, 61),
  Color.fromARGB(255, 249, 196, 61),
  Color(0xffF96F3D),
  Color.fromARGB(255, 249, 61, 77),
  Color.fromARGB(255, 249, 61, 227),
  Color.fromARGB(255, 177, 61, 249),
  Color.fromARGB(255, 61, 64, 249),
  Color.fromARGB(255, 61, 133, 249),
  Color.fromARGB(255, 61, 230, 249),
  Color.fromARGB(255, 61, 249, 189),
  Color.fromARGB(255, 61, 249, 86),
];

Future<(String iconName, Color iconColor)?> showSelectIconWithColorModal(
    BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey,
    String? alreadySelectedIcoName,
    String? titleSuffix,
    Color? alreadySelectedIconColor,
    bool? disableColorSelect}) async {
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
          titleSuffix: titleSuffix,
          disableColorSelect: disableColorSelect,
        );
      });
}

class SelectIconWithColorModalContent extends StatefulWidget {
  const SelectIconWithColorModalContent({
    super.key,
    required this.modalPadding,
    this.alreadySelectedIcoName,
    this.alreadySelectedIconColor,
    this.titleSuffix,
    this.disableColorSelect,
  });

  final double modalPadding;
  final Color? alreadySelectedIconColor;
  final bool? disableColorSelect;
  final String? alreadySelectedIcoName;

  final String? titleSuffix;

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
          child: CustomShadowWidget(
            child: Container(
              color: CustomThemeProvider.of(context).theme.bgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Navbar(
                    backInsteadOfCloseIcon: false,
                    closeFunction: () {
                      navigatorKey.currentState!.pop(null);
                    },
                    menuOpen: null,
                    useTopSafePadding: false,
                    titleWidget: Text(
                      "${S.of(context).selectIconModalTitle}${(widget.titleSuffix ?? "")}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              CustomThemeProvider.of(context).theme.textColor,
                          fontSize: 24),
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
                                  if (widget.disableColorSelect != true)
                                    Text(
                                      S.of(context).selectAColor,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkTextColor,
                                            fontSize: 24,
                                          ),
                                    ),
                                  // show colors:
                                  if (widget.disableColorSelect != true)
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: allIconColors
                                          .map((color) => CustomButton(
                                                isSubbutton: false,
                                                variant:
                                                    selectedIconColor == color
                                                        ? CustomButtonVariant
                                                            .DarkButton
                                                        : CustomButtonVariant
                                                            .Default,
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
                                  if (widget.disableColorSelect != true)
                                    SizedBox(
                                      height: 20,
                                    ),

                                  Text(
                                    S.of(context).selectAnIcon,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          color: CustomThemeProvider.of(context)
                                              .theme
                                              .darkTextColor,
                                          fontSize: 24,
                                        ),
                                  ),

                                  // show icons:
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: allIconNames
                                        .map((name) => CustomButton(
                                              isSubbutton: false,
                                              variant: selectedIconName == name
                                                  ? CustomButtonVariant
                                                      .DarkButton
                                                  : CustomButtonVariant.Default,
                                              onPressed: () {
                                                setState(() {
                                                  selectedIconName = name;
                                                });
                                              },
                                              icon: getIconForIdentifier(
                                                name: name,
                                                color: selectedIconName == name
                                                    ? CustomThemeProvider.of(
                                                            context)
                                                        .theme
                                                        .bgColor
                                                    : CustomThemeProvider.of(
                                                            context)
                                                        .theme
                                                        .darkTextColor,
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
                                    S.of(context).preview,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: CustomThemeProvider.of(context)
                                              .theme
                                              .darkTextColor,
                                          fontSize: 24,
                                        ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  CustomItemCard(
                                    scalarOverride: 1,
                                    title: S.of(context).item,
                                    description:
                                        S.of(context).itemExampleDescription,
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
                        CustomButton(
                          label: S.of(context).select,
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
