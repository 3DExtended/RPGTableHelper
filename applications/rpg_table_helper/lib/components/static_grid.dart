import 'package:flutter/cupertino.dart';

class StaticGrid extends StatelessWidget {
  const StaticGrid({
    super.key,
    this.columnCount = 2,
    this.colGap,
    this.rowGap,
    this.padding,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.center,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    required this.children,
    this.expandedFlexValues,
  });

  final List<int>? expandedFlexValues;
  final int columnCount;
  final double? colGap;
  final double? rowGap;
  final EdgeInsets? padding;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: columnCrossAxisAlignment,
        mainAxisAlignment: columnMainAxisAlignment,
        children: _createRows(),
      ),
    );
  }

  List<Widget> _createRows() {
    final List<Widget> rows = [];
    final childrenLength = children.length;
    final rowCount = (childrenLength / columnCount).ceil();

    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final List<Widget> columns = _createCells(rowIndex);
      rows.add(
        Row(
          crossAxisAlignment: rowCrossAxisAlignment,
          mainAxisAlignment: rowMainAxisAlignment,
          children: columns,
        ),
      );
      if (rowIndex != rowCount - 1) {
        rows.add(SizedBox(height: rowGap));
      }
    }

    return rows;
  }

  List<Widget> _createCells(int rowIndex) {
    final List<Widget> columns = [];
    final childrenLength = children.length;

    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      final cellIndex = rowIndex * columnCount + columnIndex;
      if (cellIndex <= childrenLength - 1) {
        columns.add(Expanded(
            flex: expandedFlexValues?[columnIndex] ?? 1,
            child: children[cellIndex]));
      } else {
        columns.add(Expanded(
            flex: expandedFlexValues?[columnIndex] ?? 1, child: Container()));
      }

      if (columnIndex != columnCount - 1) {
        columns.add(SizedBox(width: colGap));
      }
    }

    return columns;
  }
}
