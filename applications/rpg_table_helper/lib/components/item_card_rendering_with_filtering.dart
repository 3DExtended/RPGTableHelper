import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_int_edit_field.dart';
import 'package:rpg_table_helper/components/custom_item_card.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/color_extension.dart';
import 'package:rpg_table_helper/helpers/custom_iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/fuzzysort.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class ItemCardRenderingWithFiltering extends StatefulWidget {
  const ItemCardRenderingWithFiltering({
    super.key,
    required List<ItemCategory> allItemCategories,
    required this.selectedItemCategoryId,
    required this.onSelectNewFilterCategory,
    required this.renderCreateButton,
    required this.isSearchFieldShowingOnStart,
    this.onAddNewItemPressed,
    required List<({RpgItem item, int amount})> items,
    this.onItemCardPressed,
    required this.hideAmount,
    required this.onEditItemAmount,
  })  : _allItemCategories = allItemCategories,
        _items = items;
  final void Function(String itemId, int newAmountValue)? onEditItemAmount;
  final bool hideAmount;
  final bool isSearchFieldShowingOnStart;
  final List<ItemCategory> _allItemCategories;
  final String? selectedItemCategoryId;
  final Function(ItemCategory e) onSelectNewFilterCategory;
  final bool renderCreateButton;
  final Future Function()? onAddNewItemPressed;
  final List<({RpgItem item, int amount})> _items;
  final Future Function(
          MapEntry<int, ({int amount, RpgItem item})> itemToRender)?
      onItemCardPressed;

  @override
  State<ItemCardRenderingWithFiltering> createState() =>
      _ItemCardRenderingWithFilteringState();
}

class _ItemCardRenderingWithFilteringState
    extends State<ItemCardRenderingWithFiltering> {
  TextEditingController searchtextEditingController = TextEditingController();

  Map<
      String,
      ({
        FuzzySearchPreparedTarget labelSearchTarget,
        FuzzySearchPreparedTarget descriptionSearchTarget
      })> preparedTargets = {};

  List<FuzzySearchResult> searchItemFilters = [];

  bool isSearchFieldShowing = false;

  List<MapEntry<int, ({int amount, RpgItem item})>> itemsToRender = [];
  Fuzzysort fuzzysort = Fuzzysort();

  @override
  void dispose() {
    searchtextEditingController.removeListener(onTextEditControllerChange);

    super.dispose();
  }

  @override
  void initState() {
    searchtextEditingController.addListener(onTextEditControllerChange);
    Future.delayed(Duration.zero, () {
      setState(() {
        isSearchFieldShowing = widget.isSearchFieldShowingOnStart;
      });
    });

    // add all items to fuzzysort targets
    for (var item in widget._items) {
      if (preparedTargets.containsKey(item.item.uuid)) continue;

      preparedTargets[item.item.uuid] = (
        labelSearchTarget: FuzzySearchPreparedTarget(
          target: item.item.name,
          identifier: "label${item.item.uuid}",
        ),
        descriptionSearchTarget: FuzzySearchPreparedTarget(
          target: item.item.description,
          identifier: "description${item.item.uuid}",
        ),
      );
    }

    onTextEditControllerChange();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ItemCardRenderingWithFiltering oldWidget) {
    onTextEditControllerChange();
    super.didUpdateWidget(oldWidget);
  }

  void onTextEditControllerChange() {
    var query = searchtextEditingController.text;

    var searchTargets = preparedTargets.values
        .map((t) => [t.labelSearchTarget, t.descriptionSearchTarget])
        .expand((i) => i)
        .toList();

    var tempResult = fuzzysort.go(query, searchTargets, null);
    setState(() {
      searchItemFilters = tempResult.reversed.toList();

      itemsToRender = (searchtextEditingController.text.isEmpty
              ? widget._items.asMap().entries
              : searchItemFilters
                  .map((r) => r.targetIdentifier)
                  .map((id) => widget._items
                      .asMap()
                      .entries
                      .firstWhere((i) => id.contains(i.value.item.uuid)))
                  .distinct(by: (r) => r.value.item.uuid))
          .toList();

      if (searchtextEditingController.text.isEmpty) {
        itemsToRender = itemsToRender.sortedBy((m) => m.value.item.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isSearchFieldShowing
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20, 0.0),
                  child: CustomTextField(
                      labelText: "Suche",
                      textEditingController: searchtextEditingController,
                      keyboardType: TextInputType.text),
                )
              : SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...[
                        ItemCategory(
                          colorCode: null,
                          iconName: null,
                          name: "Alles",
                          subCategories: [],
                          uuid: "",
                          hideInInventoryFilters: false,
                        ),
                        ...CustomIterableExtensions(widget._allItemCategories)
                            .sortBy((e) => e.name),
                      ].map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: CustomButton(
                            variant: (widget.selectedItemCategoryId == e.uuid ||
                                    (e.uuid == "" &&
                                        widget.selectedItemCategoryId == null))
                                ? CustomButtonVariant.DarkButton
                                : CustomButtonVariant.Default,
                            onPressed: () {
                              widget.onSelectNewFilterCategory(e);
                            },
                            label: e.name,
                            icon: e.iconName == null
                                ? null
                                : getIconForIdentifier(
                                        name: e.iconName!,
                                        size: 20,
                                        color: (widget.selectedItemCategoryId ==
                                                    e.uuid ||
                                                (e.uuid == "" &&
                                                    widget.selectedItemCategoryId ==
                                                        null))
                                            ? (e.colorCode
                                                ?.parseHexColorRepresentation())
                                            : darkColor)
                                    .$2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              CustomButton(
                  variant: isSearchFieldShowing
                      ? CustomButtonVariant.DarkButton
                      : CustomButtonVariant.Default,
                  icon: CustomFaIcon(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    color: isSearchFieldShowing ? textColor : darkColor,
                    size: 21,
                    noPadding: true,
                  ),
                  onPressed: () {
                    setState(() {
                      isSearchFieldShowing = !isSearchFieldShowing;
                      searchtextEditingController.text = "";
                      onTextEditControllerChange();
                    });
                  }),
              if (widget.renderCreateButton &&
                  widget.onAddNewItemPressed != null)
                SizedBox(
                  width: 10,
                ),
              if (widget.renderCreateButton &&
                  widget.onAddNewItemPressed != null)
                CustomButton(
                  variant: CustomButtonVariant.AccentButton,
                  onPressed: widget.onAddNewItemPressed,
                  label: "+ Hinzufügen",
                )
            ],
          ),
        ),
        SizedBox(
          height: 0,
        ),
        Expanded(child: LayoutBuilder(builder: getListOfItemCardsAsColumns))
      ],
    );
  }

  Widget getListOfItemCardsAsColumns(context, constraints) {
    var layoutWidth = constraints.maxWidth;
    const scalar = 1.0;

    const cardWidth = 289 * scalar;

    const targetedCardWidth = cardWidth;
    const itemCardPadding = 9.0;

    var numberOfColumnsOnScreen = 1;
    var calculatedWidth = itemCardPadding + targetedCardWidth;

    while (calculatedWidth < layoutWidth) {
      calculatedWidth += itemCardPadding + targetedCardWidth;
      numberOfColumnsOnScreen++;
    }

    numberOfColumnsOnScreen--;

    var itemsAsMapList = itemsToRender.where((it) {
      var itemCategoryForItem =
          ItemCategory.parentCategoryForCategoryIdRecursive(
              categories: widget._allItemCategories,
              categoryId: it.value.item.categoryId);

      return widget.selectedItemCategoryId == null ||
          it.value.item.categoryId == widget.selectedItemCategoryId ||
          (itemCategoryForItem != null &&
              itemCategoryForItem.uuid == widget.selectedItemCategoryId);
    }).toList();

    if (itemsAsMapList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Text(
            "Keine Items unter dieser Kategorie",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 24, color: darkTextColor),
          ),
        ],
      );
    }
    var flattenedCategories = ItemCategory.flattenCategoriesRecursive(
        categories: widget._allItemCategories);

    return ListView.builder(
      itemCount: ((itemsAsMapList.length ~/ numberOfColumnsOnScreen) *
                  numberOfColumnsOnScreen ==
              itemsAsMapList.length)
          ? (itemsAsMapList.length ~/ numberOfColumnsOnScreen)
          : (itemsAsMapList.length ~/ numberOfColumnsOnScreen) + 1,
      itemBuilder: (context, index) {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...List.generate(numberOfColumnsOnScreen, (subindex) {
            var indexOfItemToRender =
                index * numberOfColumnsOnScreen + subindex;
            if (indexOfItemToRender >= itemsAsMapList.length) {
              return List<Widget>.empty();
            }

            var itemToRender = itemsAsMapList[indexOfItemToRender];
            var categoryForItem = flattenedCategories.firstWhereOrNull(
                (e) => e.uuid == itemToRender.value.item.categoryId);

            var parentCategoryOfItem = categoryForItem != null
                ? flattenedCategories.firstWhereOrNull((fc) => fc.subCategories
                        .any((sub) => sub.uuid == categoryForItem.uuid)) ??
                    categoryForItem
                : categoryForItem;

            return [
              Column(
                children: [
                  CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if (widget.onItemCardPressed != null) {
                        await widget.onItemCardPressed!(itemToRender);
                      }
                    },
                    child: CustomItemCard(
                      scalarOverride: scalar,
                      imageUrl: itemToRender.value.item.imageUrlWithoutBasePath,
                      title: itemToRender.value.item.name,
                      description: itemToRender.value.item.description,
                      categoryIconColor: parentCategoryOfItem?.colorCode
                          ?.parseHexColorRepresentation(),
                      categoryIconName: parentCategoryOfItem?.iconName,
                    ),
                  ),
                  if (widget.hideAmount != true &&
                      widget.onEditItemAmount == null)
                    SizedBox(
                      height: 5,
                    ),
                  if (widget.hideAmount != true &&
                      widget.onEditItemAmount == null)
                    Text(
                      "Anzahl: ${itemToRender.value.amount}",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: darkTextColor,
                            fontSize: 16,
                          ),
                    ),
                  if (widget.onEditItemAmount != null)
                    SizedBox(
                      height: 5,
                    ),
                  if (widget.onEditItemAmount != null)
                    CustomIntEditField(
                      key: ValueKey(
                          "ItemEditField${itemToRender.value.item.uuid}"),
                      onValueChange: (newValue) {
                        widget.onEditItemAmount!(
                            itemToRender.value.item.uuid, newValue);
                      },
                      minValue: 0,
                      maxValue: 999,
                      label: "Hinzufügen",
                      startValue: itemToRender.value.amount,
                    ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              if (numberOfColumnsOnScreen != subindex + 1)
                SizedBox(
                  width: itemCardPadding,
                ),
            ];
          }).expand((i) => i),
        ]);
      },
    );
  }
}
