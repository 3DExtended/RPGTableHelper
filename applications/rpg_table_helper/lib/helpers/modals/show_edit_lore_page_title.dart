import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';

Future<({String title, String groupName})?> showEditLorePageTitle(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  required String currentTitle,
  required String currentGroupTitle,
  required List<String> allGroupTitles,
}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
          ({String title, String groupName})>(
      isDismissible: true,
      expand: false,
      closeProgressThreshold: -50000,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      enableDrag: true,
      context: context,
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return ShowEditLorePageModalContent(
          modalPadding: modalPadding,
          currentTitle: currentTitle,
          currentGroupTitle: currentGroupTitle,
          allGroupTitles: allGroupTitles,
          overrideNavigatorKey: overrideNavigatorKey,
        );
      });
}

class ShowEditLorePageModalContent extends StatefulWidget {
  const ShowEditLorePageModalContent({
    super.key,
    required this.modalPadding,
    required this.currentTitle,
    required this.allGroupTitles,
    required this.currentGroupTitle,
    this.overrideNavigatorKey,
  });

  final double modalPadding;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  final String currentTitle;
  final List<String> allGroupTitles;
  final String currentGroupTitle;

  @override
  State<ShowEditLorePageModalContent> createState() =>
      _ShowEditLorePageModalContentState();
}

class _ShowEditLorePageModalContentState
    extends State<ShowEditLorePageModalContent> {
  var titleTextEditor = TextEditingController();
  var groupTitleTextEditor = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        titleTextEditor.text = widget.currentTitle;
        groupTitleTextEditor.text = widget.currentGroupTitle;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<({String title, String groupName})>(
      isFullscreen: false,
      title: S.of(context).editPageTitle,
      navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
      onCancel: () async {},
      onSave: () async {
        return (
          title: titleTextEditor.text,
          groupName: groupTitleTextEditor.text
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomMarkdownBody(
            text: S.of(context).editPageModalText,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextField(
            keyboardType: TextInputType.text,
            labelText: S.of(context).documentTitleLabel,
            textEditingController: titleTextEditor,
          ),
          SizedBox(
            height: 10,
          ),
          CustomTextField(
            keyboardType: TextInputType.text,
            labelText: S.of(context).documentGroupLabel,
            textEditingController: groupTitleTextEditor,
          ),
        ],
      ),
    );
  }
}
