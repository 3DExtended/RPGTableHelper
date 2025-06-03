import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';

class DynamicHeightColumnLayout extends StatefulWidget {
  final List<Widget> children;
  final int numberOfColumns;

  final double spacing;
  final double runSpacing;

  const DynamicHeightColumnLayout({
    super.key,
    required this.children,
    this.numberOfColumns = 2,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
  });

  @override
  DynamicHeightColumnLayoutState createState() =>
      DynamicHeightColumnLayoutState();
}

class DynamicHeightColumnLayoutState extends State<DynamicHeightColumnLayout> {
  Map<int, int>? childMapping;

  late List<GlobalKey> childrenKeys;

  Map<int, double> childrenPaddingTops = {};

  @override
  void initState() {
    childrenKeys =
        List.generate(widget.children.length, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryCounter = 0;

      assignChildrenToCorrectColumn();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicHeightColumnLayout oldWidget) {
    Future.delayed(Duration.zero, () {
      _retryCounter = 0;

      assignChildrenToCorrectColumn();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Columns data structure: A list of child lists for each column.
    List<List<Widget>> columns =
        List.generate(widget.numberOfColumns, (_) => []);

    // Temporarily measure heights of each child and distribute them into columns.
    for (var i = 0; i < widget.children.length; i++) {
      var child = widget.children[i];

      var targetColumnIndex = i % widget.numberOfColumns;
      if (childMapping != null && childMapping!.containsKey(i)) {
        targetColumnIndex = childMapping![i]! % widget.numberOfColumns;
      }

      // Add the child to the target column.
      if (childrenPaddingTops.containsKey(i) && childrenPaddingTops[i] != 0.0) {
        columns[targetColumnIndex].add(Container(
          height: childrenPaddingTops[i],
          color: Colors.transparent,
        ));
      }
      columns[targetColumnIndex].add(Container(
        padding: EdgeInsets.only(bottom: widget.runSpacing),
        key: childrenKeys.length > i ? childrenKeys[i] : null,
        child: child,
      ));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.numberOfColumns, (index) {
        return (Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns[index],
          ),
        ) as Widget);
      }).insertBetween(SizedBox(
        width: widget.spacing,
      )),
    );
  }

  var _retryCounter = 0;
  void assignChildrenToCorrectColumn() {
    if (_retryCounter >= 5) return;
    _retryCounter++;

    Map<int, int> tempMapping = {};

    var heightsOfChildren = childrenKeys
        .map((key) => key.currentContext?.size?.height ?? -1)
        .toList()
        .asMap()
        .entries
        .where((e) => e.value >= 0)
        .toList();

    if (heightsOfChildren.length != widget.children.length) {
      Future.delayed(Duration.zero, () {
        assignChildrenToCorrectColumn();
      });
    }

    childrenPaddingTops = {};

    var screensize = MediaQuery.of(context).size;

    // if there are multiple children which exceed the screen height, we return the default mapping from the default configuration
    var itemsWithExceedingHeight =
        heightsOfChildren.map((e) => e.value > screensize.height).toList();
    if (itemsWithExceedingHeight.where((e) => e == true).length >=
        widget.numberOfColumns) {
      var indexOfFirstExceedingHeight = itemsWithExceedingHeight.indexOf(true);

      // loop through each child and assign it to the column based on its index
      var columnIndex = 0;
      for (var i = 0; i < widget.children.length; i++) {
        // if the current child is the first one that exceeds the height, we
        // need to calculate the heights of all columns up to this point and
        // align all following children to the bottom of the row
        if (indexOfFirstExceedingHeight == i) {
          // calculate the heights of all columns up to this point
          var currentColumnHeights = List.filled(
            widget.numberOfColumns,
            0.0,
          );
          for (var j = 0; j < widget.numberOfColumns; j++) {
            currentColumnHeights[j] = heightsOfChildren
                .where((e) => tempMapping[e.key] == j)
                .fold(0.0, (sum, e) => sum + e.value);
          }
          var maxCurrentColumnHeight =
              currentColumnHeights.reduce((a, b) => a > b ? a : b);

          for (var j = 0; j < widget.numberOfColumns; j++) {
            var paddingBottom =
                max(0.0, maxCurrentColumnHeight - currentColumnHeights[j]);
            childrenPaddingTops[i + j] = context.isTablet
                ? paddingBottom
                : 0; // Adjust padding for tablet vs phone
          }

          columnIndex = 0;
        }

        tempMapping[i] = columnIndex % widget.numberOfColumns;
        columnIndex++;
      }
    } else {
      List<double> columnHeights = List.filled(widget.numberOfColumns, 0.0);
      for (var i = 0; i < widget.children.length; i++) {
        var childHeight =
            heightsOfChildren.length > i ? heightsOfChildren[i].value : 0.0;
        int targetColumnIndex = columnHeights.indexOf(
          columnHeights.reduce((a, b) => a < b ? a : b),
        );
        tempMapping[i] = targetColumnIndex;
        columnHeights[targetColumnIndex] += childHeight;
      }
    }

    if (!mounted) return;
    setState(() {
      childMapping = tempMapping;
    });
  }
}
