import 'package:flutter/material.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';

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

  @override
  void initState() {
    childrenKeys =
        List.generate(widget.children.length, (index) => GlobalKey());

    Future.delayed(Duration.zero, () {
      assignChildrenToCorrectColumn();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicHeightColumnLayout oldWidget) {
    Future.delayed(Duration.zero, () {
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

  void assignChildrenToCorrectColumn() {
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

    if (!mounted) return;
    setState(() {
      childMapping = tempMapping;
    });
  }
}

class MeasureHeightWidget extends StatelessWidget {
  final Widget child;

  const MeasureHeightWidget({super.key, required this.child});

  // This widget wraps the child and calculates its height when rendered.
  @override
  Widget build(BuildContext context) {
    return child;
  }

  double measure(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.hasSize ? renderBox.size.height : 0;
  }
}
