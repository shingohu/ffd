import 'package:flutter/material.dart';

///按列个数平分行,并且自动换行
///适合宽高确定的
class FixedSizeRowWrap extends StatelessWidget {
  final double spacing;
  final double runSpacing;
  final int columnCount;
  final List<Widget> children;

  FixedSizeRowWrap({Key? key, this.spacing = 0, this.runSpacing = 0, required this.columnCount, required this.children}) : super(key: key);

  @override
  build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (columnCount - 1)) ~/ columnCount;
        final rows = children.length % columnCount != 0 ? (children.length ~/ columnCount) + 1 : (children.length ~/ columnCount);
        final itemHeight = (constraints.maxHeight - runSpacing * (rows - 1)) ~/ rows;

        return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((widget) {
              return SizedBox(width: itemWidth.toDouble(), height: itemHeight.toDouble(), child: widget);
            }).toList());
      },
    );
  }
}

///根据宽度,个数自动换行,
///Item的宽高一样
class FixedWidthRowWrap extends StatelessWidget {
  final double spacing; //横向的间距
  final double runSpacing; //纵向的间距
  final int columnCount;
  final List<Widget> children;

  FixedWidthRowWrap({Key? key, this.spacing = 0, this.runSpacing = 0, required this.columnCount, required this.children}) : super(key: key);

  @override
  build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (columnCount - 1)) ~/ columnCount;

        final itemHeight = itemWidth;

        return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((widget) {
              return SizedBox(width: itemWidth.toDouble(), height: itemHeight.toDouble(), child: widget);
            }).toList());
      },
    );
  }
}

///根据宽度,个数自动换行,
class FixedColumnWrap extends StatelessWidget {
  final double spacing; //横向的间距
  final double runSpacing; //纵向的间距
  final int column;
  final List<Widget> children;

  FixedColumnWrap({Key? key, this.spacing = 0, this.runSpacing = 0, required this.column, required this.children}) : super(key: key);

  @override
  build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (column - 1)) ~/ column;
        return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((widget) {
              return SizedBox(width: itemWidth.toDouble(), child: widget);
            }).toList());
      },
    );
  }
}
