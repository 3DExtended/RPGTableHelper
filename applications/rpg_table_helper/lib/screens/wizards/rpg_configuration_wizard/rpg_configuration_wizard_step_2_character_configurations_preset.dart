import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep2CharacterConfigurationsPreset
    extends WizardStepBase {
  const RpgConfigurationWizardStep2CharacterConfigurationsPreset({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep2CharacterConfigurationsPreset>
      createState() =>
          _RpgConfigurationWizardStep2CharacterConfigurationsPresetState();
}

class _RpgConfigurationWizardStep2CharacterConfigurationsPresetState
    extends ConsumerState<
        RpgConfigurationWizardStep2CharacterConfigurationsPreset> {
  bool hasDataLoaded = false;
  List<
      (
        String uuid,
        TextEditingController tabName,
        bool isOptional,
        bool isDefaultTab,
      )> tabsToEdit = [];

  Map<String, List<CharacterStatDefinition>> statsUnderTab = {};

  bool isFormValid = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      setState(() {
        if (hasDataLoaded) return;
        hasDataLoaded = true;

        var loadedTabs = (data.characterStatTabsDefinition ??
            RpgConfigurationModel.getBaseConfiguration()
                .characterStatTabsDefinition!);

        for (var tab in loadedTabs) {
          tabsToEdit.add((
            tab.uuid,
            TextEditingController(text: tab.tabName),
            tab.isOptional,
            tab.isDefaultTab
          ));

          for (var stat in tab.statsInTab) {
            statsUnderTab.putIfAbsent(tab.uuid, () => []).add(stat);
          }
        }
      });
    });

    var stepHelperText = '''

Nun kommen wir zu den Character Sheets.

Jedes RPG hat unterschiedliche charakterisierende Eigenschaften für die Spieler (bspw. wieviele Lebenspunkte ein Spieler hat).

Für jede Eigenschaft muss du, also der DM, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei brauchen wir je Eigenschaft drei Infos von dir:

1. Name der Eigenschaft: Wie soll dieser Stat auf dem Character Sheet heißen? (bspw. “HP”, “SP”, “Name”, etc.)
2. Werteart der Eigenschaft: Handelt es sich bspw. nur um einen Text, welchen der Spieler anpassen kann (bspw. Hintergrund Story zum Character) oder doch um einen Zahlenwert (bspw. den Lebenspunkten).
3. Änderungsart: Manche von diesen Eigenschaften werden regelmäßig angepasst (bspw. die aktuellen Lebenspunkte), manche hingegen werden nur selten verändert (bspw. die maximalen Lebenspunkte). Damit das bei der Erstellung der Charactersheets berücksichtig werden kann, musst du uns diese Information mitgeben.

Falls du mehr Erklärung brauchst, kannst du hier eine Beispielseite mit allen Konfigurationen und entsprechendem Aussehen auf den Character Sheets finden:'''; // TODO localize

    return TwoPartWizardStepBody(
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Character Stats", // TODO Localize,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              saveChanges();
              widget.onNextBtnPressed();
            },
      onPreviousBtnPressed: () {
        saveChanges();

        widget.onPreviousBtnPressed();
      },
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        ...tabsToEdit.asMap().entries.map((tab) {
          return Column(
            children: [
              // Tab title textfield
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: "Tab Title",
                      textEditingController: tab.value.$2,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Default Tab"),
                      SizedBox(
                        height: 5,
                      ),
                      CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          setState(() {
                            var newTabsToEdit = [...tabsToEdit];
                            for (var i = 0; i < newTabsToEdit.length; i++) {
                              newTabsToEdit[i] = (
                                newTabsToEdit[i].$1,
                                newTabsToEdit[i].$2,
                                newTabsToEdit[i].$3,
                                i == tab.key
                              );
                            }
                            tabsToEdit = newTabsToEdit;
                          });
                        },
                        child: StyledBox(
                          child: Container(
                            width: 20,
                            height: 20,
                            color: tab.value.$4
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),

              // stats beneath
              ...(statsUnderTab[tab.value.$1] ?? []).asMap().entries.map(
                    (e) => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        156, 255, 255, 255),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomMarkdownBody(
                                        text:
                                            "### ${e.value.name} (${e.value.valueType.toCustomString()})",
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        // Edit Button
                        Container(
                          height: 50,
                          width: 50,
                          clipBehavior: Clip.none,
                          child: CustomButton(
                            onPressed: () async {
                              await showGetDmConfigurationModal(
                                      context: context,
                                      predefinedConfiguration: e.value)
                                  .then((value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  statsUnderTab[tab.value.$1]![e.key] = (value);
                                });
                              });
                            },
                            icon: const CustomFaIcon(
                                icon: FontAwesomeIcons.penToSquare),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 70,
                          clipBehavior: Clip.none,
                          child: CustomButton(
                            onPressed: () {
                              setState(() {
                                statsUnderTab[tab.value.$1]!.removeAt(e.key);
                              });
                            },
                            icon: const CustomFaIcon(
                                icon: FontAwesomeIcons.trashCan),
                          ),
                        ),
                      ],
                    ),
                  ),

              // add new stat beneath
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                child: CustomButton(
                  isSubbutton: true,
                  onPressed: () async {
                    // open new modal for dm config
                    // if it returns non null add the stat
                    await showGetDmConfigurationModal(context: context)
                        .then((value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        statsUnderTab
                            .putIfAbsent(tab.value.$1, () => [])
                            .add(value);
                      });
                    });
                  },
                  label: "Neue Eigenschaft",
                  icon: Theme(
                      data: ThemeData(
                        iconTheme: const IconThemeData(
                          color: Colors.white,
                          size: 16,
                        ),
                        textTheme: const TextTheme(
                          bodyMedium: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Container(
                            width: 16,
                            height: 16,
                            alignment: AlignmentDirectional.center,
                            child: const FaIcon(FontAwesomeIcons.plus)),
                      )),
                ),
              ),
            ],
          );
        }),

        // add new tab button
        CustomButton(
          onPressed: () {
            addNewTab();
          },
          icon: Theme(
              data: ThemeData(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              child: Container(
                  width: 24,
                  height: 24,
                  alignment: AlignmentDirectional.center,
                  child: const FaIcon(FontAwesomeIcons.plus))),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewTab() {
    setState(() {
      var newId = UuidV7().generate();

      tabsToEdit.add((
        newId,
        TextEditingController(),
        false, // isOptional
        tabsToEdit.isEmpty, // isDefaultTab
      ));

      statsUnderTab[newId] = [];
    });
  }

  void saveChanges() {
    var constructedTabs = tabsToEdit
        .map((tuple) => CharacterStatsTabDefinition(
              isOptional: tuple.$3,
              isDefaultTab: tuple.$4,
              tabName: tuple.$2.text,
              uuid: tuple.$1,
              statsInTab: statsUnderTab[tuple.$1] ?? [],
            ))
        .toList();

    ref
        .read(rpgConfigurationProvider.notifier)
        .updateCharacterScreenStatsTabs(constructedTabs);
  }
}

extension on CharacterStatValueType {
  toCustomString() {
    switch (this) {
      case CharacterStatValueType.int:
        return "Zahlen-Wert";
      case CharacterStatValueType.intWithMaxValue:
        return "Zahlen-Wert mit maximal Wert";
      case CharacterStatValueType.intWithCalculatedValue:
        return "Zahlen-Wert mit zusätzlicher Zahl";
      case CharacterStatValueType.multiLineText:
        return "Mehrzeiliger Text";
      case CharacterStatValueType.singleLineText:
        return "Einzeiliger Text";
      case CharacterStatValueType.multiselect:
        return "Mehrfach-Auswahl";

      default:
    }
  }
}
