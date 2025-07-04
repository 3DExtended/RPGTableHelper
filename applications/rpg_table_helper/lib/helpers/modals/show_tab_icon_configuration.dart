import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/modals/show_select_icon_with_color_modal.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

Future<List<RpgTabConfiguration>?> showTabIconConfiguration(
    {required BuildContext context,
    GlobalKey<NavigatorState>? overrideNavigatorKey,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfiguration? rpgCharacterToRender}) async {
  return await customShowCupertinoModalBottomSheet<List<RpgTabConfiguration>>(
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

        return TabIconConfigurationModalContent(
          modalPadding: modalPadding,
          rpgCharacterToRender: rpgCharacterToRender,
          rpgConfig: rpgConfig,
        );
      });
}

class TabIconConfigurationModalContent extends ConsumerStatefulWidget {
  final double modalPadding;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration? rpgCharacterToRender;
  const TabIconConfigurationModalContent(
      {super.key,
      required this.modalPadding,
      required this.rpgCharacterToRender,
      required this.rpgConfig});

  @override
  ConsumerState<TabIconConfigurationModalContent> createState() =>
      _TabIconConfigurationModalContentState();
}

class _TabIconConfigurationModalContentState
    extends ConsumerState<TabIconConfigurationModalContent> {
  List<(String uuid, String name, String? iconName)> tabIcons = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        tabIcons = widget.rpgConfig.characterStatTabsDefinition
                ?.map((e) => (
                      e.uuid,
                      e.tabName,
                      widget.rpgCharacterToRender?.tabConfigurations
                          ?.where((t) => t.tabUuid == e.uuid)
                          .firstOrNull
                          ?.tabIcon
                    ))
                .toList() ??
            [];
        tabIcons.addAll([
          (
            "money_tab_uuid",
            S.of(context).navBarHeaderMoney,
            widget.rpgCharacterToRender?.tabConfigurations
                ?.where((t) => t.tabUuid == "money_tab_uuid")
                .firstOrNull
                ?.tabIcon
          ),
          (
            "inventory_tab_uuid",
            S.of(context).navBarHeaderInventory,
            widget.rpgCharacterToRender?.tabConfigurations
                ?.where((t) => t.tabUuid == "inventory_tab_uuid")
                .firstOrNull
                ?.tabIcon
          ),
          (
            "recipes_tab_uuid",
            S.of(context).navBarHeaderCrafting,
            widget.rpgCharacterToRender?.tabConfigurations
                ?.where((t) => t.tabUuid == "recipes_tab_uuid")
                .firstOrNull
                ?.tabIcon
          ),
          (
            "lore_tab_uuid",
            S.of(context).navBarHeaderLore,
            widget.rpgCharacterToRender?.tabConfigurations
                ?.where((t) => t.tabUuid == "lore_tab_uuid")
                .firstOrNull
                ?.tabIcon
          ),
        ]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    S.of(context).tabIconsConfigurationTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: CustomThemeProvider.of(context)
                                    .brightnessNotifier
                                    .value ==
                                Brightness.light
                            ? CustomThemeProvider.of(context).theme.textColor
                            : CustomThemeProvider.of(context)
                                .theme
                                .darkTextColor,
                        fontSize: 24),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...tabIcons.asMap().entries.map(
                                (en) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: CustomThemeProvider.of(
                                                              context)
                                                          .brightnessNotifier
                                                          .value ==
                                                      Brightness.light
                                                  ? CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .middleBgColor
                                                  : CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .bgColor
                                                      .lighter(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  en.value.$2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          color: CustomThemeProvider
                                                                  .of(context)
                                                              .theme
                                                              .darkTextColor),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              // Icon selection button
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 10, 0),
                                                child: CustomButton(
                                                  isSubbutton: true,
                                                  variant: CustomButtonVariant
                                                      .Default,
                                                  onPressed: () async {
                                                    // open icon and color selector
                                                    await showSelectIconWithColorModal(
                                                            context,
                                                            hideItemCard: true,
                                                            disableColorSelect:
                                                                true,
                                                            alreadySelectedIcoName:
                                                                en.value.$3,
                                                            alreadySelectedIconColor:
                                                                CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .accentColor,
                                                            titleSuffix:
                                                                " (für Tab ${en.value.$2})")
                                                        .then((value) {
                                                      if (value == null) {
                                                        return;
                                                      }

                                                      setState(() {
                                                        tabIcons[en.key] = (
                                                          en.value.$1,
                                                          en.value.$2,
                                                          value.$1
                                                        );
                                                      });
                                                    });
                                                  },
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.5),
                                                    child: en.value.$3 == null
                                                        ? SizedBox(
                                                            width: 32,
                                                            height: 32,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                              child: Transform
                                                                  .rotate(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                angle: pi /
                                                                    4, // 45 deg
                                                                child:
                                                                    CustomFaIcon(
                                                                  icon: FontAwesomeIcons
                                                                      .square,
                                                                  size: 32,
                                                                  color: CustomThemeProvider.of(
                                                                          context)
                                                                      .theme
                                                                      .darkColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : getIconForIdentifier(
                                                            name: en.value.$3!,
                                                            color: CustomThemeProvider
                                                                    .of(context)
                                                                .theme
                                                                .darkColor,
                                                            size: 32,
                                                          ).$2,
                                                  ),
                                                ),
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
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                  child: Row(
                    children: [
                      const Spacer(),
                      CustomButton(
                        label: S.of(context).cancel,
                        onPressed: () {
                          navigatorKey.currentState!.pop(null);
                        },
                      ),
                      const Spacer(),
                      CustomButton(
                        label: S.of(context).save,
                        onPressed: () {
                          var list = tabIcons
                              .where((e) => e.$3 != null)
                              .map((e) => RpgTabConfiguration(
                                    tabUuid: e.$1,
                                    tabIcon: e.$3!,
                                  ))
                              .toList();

                          navigatorKey.currentState!.pop(list);
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
