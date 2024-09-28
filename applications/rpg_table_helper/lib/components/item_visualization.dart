import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class ItemVisualization extends StatelessWidget {
  const ItemVisualization({
    super.key,
    required this.itemToRender,
    required this.renderRecipeRelatedThings,
    required this.itemNameSuffix,
    required this.numberOfItemsInInventory,
    required this.numberOfCreateableInstances,
    required this.craftItem,
    required this.useItem,
  });

  final RpgItem itemToRender;
  final bool renderRecipeRelatedThings;
  final String? itemNameSuffix;
  final int numberOfItemsInInventory;
  final int? numberOfCreateableInstances;
  final void Function() craftItem;
  final void Function()? useItem;

  @override
  Widget build(BuildContext context) {
    return StyledBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  itemToRender.name +
                      (renderRecipeRelatedThings ? (itemNameSuffix ?? "") : ""),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      text: itemToRender.description,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Colors.white, fontSize: 14),
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const HorizontalLine(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    "Im Besitz: ",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    numberOfItemsInInventory.toString(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  if (renderRecipeRelatedThings)
                    Text(
                      "Herstellbar: ",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Colors.white, fontSize: 14),
                    ),
                  if (renderRecipeRelatedThings)
                    Text(
                      numberOfCreateableInstances.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Colors.white, fontSize: 14),
                    ),
                  if (renderRecipeRelatedThings) const Spacer(),
                  if (!renderRecipeRelatedThings &&
                      useItem != null &&
                      numberOfItemsInInventory != 0)
                    const Spacer(),
                  if (!renderRecipeRelatedThings &&
                      useItem != null &&
                      numberOfItemsInInventory != 0)
                    Center(
                      child: CupertinoButton(
                        onPressed: useItem!,
                        minSize: 0,
                        padding: const EdgeInsets.all(0),
                        child: StyledBox(
                          borderRadius: 5,
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: CustomFaIcon(
                                icon: FontAwesomeIcons.handSparkles),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (renderRecipeRelatedThings && numberOfCreateableInstances != 0)
                const SizedBox(
                  height: 10,
                ),
              if (renderRecipeRelatedThings && numberOfCreateableInstances != 0)
                Center(
                  child: CupertinoButton(
                    onPressed: craftItem,
                    minSize: 0,
                    padding: const EdgeInsets.all(0),
                    child: StyledBox(
                      borderRadius: 5,
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CustomFaIcon(icon: FontAwesomeIcons.plus),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
