import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';

import '../../../helpers/modal_helpers.dart';

Future showChoosePlayerOrDmModal(BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: true,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    builder: (context) => const ChoosePlayerOrDmModalContent(),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class ChoosePlayerOrDmModalContent extends ConsumerStatefulWidget {
  const ChoosePlayerOrDmModalContent({super.key});

  @override
  ConsumerState<ChoosePlayerOrDmModalContent> createState() =>
      _ChoosePlayerOrDmModalContentState();
}

class _ChoosePlayerOrDmModalContentState
    extends ConsumerState<ChoosePlayerOrDmModalContent> {
  TextEditingController sessionCodeController = TextEditingController();
  TextEditingController playerNameController = TextEditingController();
  TextEditingController dmCampagneNameController = TextEditingController();

  bool hasConnectionDataLoaded = false;
  bool hasRpgConfigDataLoaded = false;

  bool isStartSessionButtonDisabled = true;
  bool isJoinSessionButtonDisabled = true;

  bool getIsStartGameButtonDisabled() {
    if (!hasConnectionDataLoaded || !hasRpgConfigDataLoaded) return false;

    if (dmCampagneNameController.text.isEmpty ||
        dmCampagneNameController.text.length < 3) {
      return false;
    }
    return true;
  }

  bool getIsJoinGameButtonDisabled() {
    if (!hasConnectionDataLoaded || !hasRpgConfigDataLoaded) return false;

    if (sessionCodeController.text.isEmpty ||
        sessionCodeController.text.length < 3) {
      return false;
    }
    if (playerNameController.text.isEmpty ||
        playerNameController.text.length < 2) {
      return false;
    }
    return true;
  }

  void _updateStateForFormValidation() {
    var newIsStartBtnValid = getIsStartGameButtonDisabled();
    var newIsJoinBtnValid = getIsJoinGameButtonDisabled();

    setState(() {
      isJoinSessionButtonDisabled = !newIsJoinBtnValid;
      isStartSessionButtonDisabled = !newIsStartBtnValid;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        sessionCodeController.text = "";
      });
    });

    playerNameController.addListener(_updateStateForFormValidation);
    dmCampagneNameController.addListener(_updateStateForFormValidation);
    sessionCodeController.addListener(_updateStateForFormValidation);

    super.initState();
  }

  @override
  void dispose() {
    playerNameController.removeListener(_updateStateForFormValidation);
    dmCampagneNameController.removeListener(_updateStateForFormValidation);
    sessionCodeController.removeListener(_updateStateForFormValidation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(connectionDetailsProvider).whenData((data) {
      if (!hasConnectionDataLoaded) {
        setState(() {
          hasConnectionDataLoaded = true;

          if (data.sessionConnectionNumberForPlayers != null) {
            sessionCodeController.text =
                data.sessionConnectionNumberForPlayers!;
          }
        });
      }
    });

    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasRpgConfigDataLoaded) {
        setState(() {
          hasRpgConfigDataLoaded = true;

          dmCampagneNameController.text = data.rpgName;
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 80.0,
          vertical: 80.0), // TODO maybe percentage of total width?
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: min(MediaQuery.of(context).size.width * 0.5, 800)),
            child: StyledBox(
              borderThickness: 1,
              child: Padding(
                padding: const EdgeInsets.all(21.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Session konfigurieren", // TODO localize/ switch text between add and edit
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: Colors.white, fontSize: 32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20.0, bottom: 10),
                        child: MarkdownBody(
                          data:
                              "Bist du der __DM__ für euer Spiel?\n\nDann gib hier den Namen euerer Kampagne an und eröffne die heutige Session!",
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              labelText: "Kampagnen Name:", // TODO localize
                              textEditingController: dmCampagneNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: CustomButton(
                          label: "Session beginnen", // TODO localize
                          onPressed: isStartSessionButtonDisabled
                              ? null
                              : () async {
                                  // add register game button
                                  final com = DependencyProvider.of(context)
                                      .getService<IServerMethodsService>();
                                  await com.registerGame(
                                      campagneName:
                                          dmCampagneNameController.text);
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const HorizontalLine(),
                      const SizedBox(
                        height: 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20.0, bottom: 10),
                        child: MarkdownBody(
                          data:
                              "Bist du __Spieler__?\n\nDann frag deinen DM nach der Session ID um der Session beizutreten:",
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              labelText: "Charakter Name:", // TODO localize
                              textEditingController: playerNameController,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              labelText: "Session ID:", // TODO localize
                              textEditingController: sessionCodeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: CustomButton(
                          label: "Session beitreten", // TODO localize
                          onPressed: isJoinSessionButtonDisabled
                              ? null
                              : () {
                                  // TODO add join game
                                },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: EdgeInsets.fromViewPadding(
                                  View.of(context).viewInsets,
                                  View.of(context).devicePixelRatio)
                              .bottom),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
