import 'package:flutter/widgets.dart';

class CustomGridListView extends StatelessWidget {
  final int numberOfColumns;
  final int itemCount;

  final double horizontalSpacing;
  final double verticalSpacing;
  final Widget? Function(BuildContext, int) itemBuilder;

  const CustomGridListView({
    super.key,
    required this.itemCount,
    required this.numberOfColumns,
    required this.itemBuilder,
    this.horizontalSpacing = 10.0,
    this.verticalSpacing = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: getRowCountForItemCount(),
        prototypeItem: itemCount == 0 ? null : _itemBuilder(context, 0),
        itemBuilder: _itemBuilder);
  }

  Widget? _itemBuilder(context, rowindex) {
    List<Widget> children = [];
    for (var i = 0; i < numberOfColumns; i++) {
      var itemIndex = rowindex * numberOfColumns + i;

      if (i != 0) {
        children.add(SizedBox(
          width: horizontalSpacing,
        ));
      }

      if (itemIndex >= itemCount) {
        // add empty object
        children.add(const Spacer());
      } else {
        children.add(
            Expanded(child: itemBuilder(context, itemIndex) ?? const Spacer()));
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: verticalSpacing),
      child: Row(
        children: children,
      ),
    );
  }

  int getRowCountForItemCount() {
    return (itemCount.toDouble() / numberOfColumns.toDouble()).ceil();
  }
}
