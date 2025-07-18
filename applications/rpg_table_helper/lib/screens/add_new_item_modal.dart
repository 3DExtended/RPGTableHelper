import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/item_card_rendering_with_filtering.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

Future<List<(String itemId, int amount)>?> showAddNewItemModal(
    BuildContext context,
    {String? itemCategoryFilter,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
      List<(String itemId, int amount)>>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) =>
        AddNewItemModalContent(itemCategoryFilter: itemCategoryFilter),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class AddNewItemModalContent extends ConsumerStatefulWidget {
  final String? itemCategoryFilter;
  const AddNewItemModalContent({
    super.key,
    this.itemCategoryFilter,
  });

  @override
  ConsumerState<AddNewItemModalContent> createState() =>
      _AddNewItemModalContentState();
}

class _AddNewItemModalContentState
    extends ConsumerState<AddNewItemModalContent> {
  TextEditingController amountController = TextEditingController();

  String? selectedItemCategoryId;
  bool hasDataLoaded = false;
  List<ItemCategory> _allItemCategories = [];
  List<({RpgItem item, int amount})> _allItems = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedItemCategoryId = widget.itemCategoryFilter;
        amountController.text = "1";
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          _allItemCategories = data.itemCategories;
          _allItems = data.allItems.map((i) => (amount: 0, item: i)).toList();
        });
      } else {
        setState(() {
          _allItems.addAll(data.allItems
              .map((i) => (amount: 0, item: i))
              .where((t) =>
                  !_allItems.map((ai) => ai.item.uuid).contains(t.item.uuid))
              .toList());
        });
      }
    });

    var modalPadding = 80.0;
    if (MediaQuery.of(context).size.width < 800) {
      modalPadding = 20.0;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(modalPadding, 20, modalPadding, 20),
        child: Center(
          child: CustomShadowWidget(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
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
                        S.of(context).addItems,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: CustomThemeProvider.of(context)
                                        .brightnessNotifier
                                        .value ==
                                    Brightness.light
                                ? CustomThemeProvider.of(context)
                                    .theme
                                    .textColor
                                : CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                            fontSize: 24),
                      ),
                    ),
                    Expanded(
                        child: ItemCardRenderingWithFiltering(
                      isSearchFieldShowingOnStart: true,
                      onEditItemAmount: (String itemId, int newAmountValue) {
                        setState(() {
                          var indexOfItemTuple = _allItems
                              .indexWhere((t) => t.item.uuid == itemId);
                          var item = _allItems
                              .firstWhere((t) => t.item.uuid == itemId);
                          _allItems[indexOfItemTuple] =
                              (amount: newAmountValue, item: item.item);
                        });
                      },
                      allItemCategories: _allItemCategories,
                      selectedItemCategoryId: selectedItemCategoryId,
                      renderCreateButton: false,
                      hideAmount: false,
                      onSelectNewFilterCategory: (e) {
                        setState(() {
                          selectedItemCategoryId = e.uuid == "" ? null : e.uuid;
                        });
                      },
                      items: _allItems,
                    )),
                    const SizedBox(
                      height: 20,
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
                            variant: CustomButtonVariant.AccentButton,
                            onPressed: () {
                              navigatorKey.currentState!.pop(_allItems
                                  .map((t) => (t.item.uuid, t.amount))
                                  .toList());
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
      ),
    );
  }
}
