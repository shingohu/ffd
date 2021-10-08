import 'package:flutter/material.dart';

abstract class AbsNode {
  ///图标
  String? nodeIcon;

  ///节点名称
  String get nodeName;

  ///子节点
  List<AbsNode>? get nodeChild;

  ///节点id
  String get nodeId;

  ///深度(0表示顶层)
  int nodeDepth = 0;

  ///是否已经展开(默认不展开,可重写)
  bool isExpanded = false;

  ///是否有子节点
  bool get hasChildren => nodeChild != null && nodeChild!.length > 0;
}

typedef TopNodeBuilder = Widget Function(AbsNode node);
typedef SubNodeBuilder = Widget Function(AbsNode node);

class TreeView extends StatelessWidget {
  final AbsNode node;
  final TopNodeBuilder? topNodeBuilder;
  final SubNodeBuilder? subNodeBuilder;
  final Widget? lineWidget;
  final double? leftPadding;
  final bool horizontalExpanded;

  TreeView({Key? key, required this.node, this.topNodeBuilder, this.subNodeBuilder, this.lineWidget, this.leftPadding = 20, this.horizontalExpanded = false}) : super(key: key);

  ///子节点View
  Widget subNodeView(AbsNode node) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          color: Colors.green,
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green),
        ),
        Container(height: 30, alignment: Alignment.center, child: Text(node.nodeName)),
      ],
    );
  }

  ///顶层节点
  Widget topNodeView(AbsNode node) {
    return Container(height: 40, child: Text(node.nodeName));
  }

  ///遍历节点
  List<Widget> recursionNode(AbsNode topNode, List<Widget> children) {
    if (topNode.hasChildren) {
      for (AbsNode node in topNode.nodeChild!) {
        List<Widget> nodeChildren = [];
        node.nodeDepth = topNode.nodeDepth + 1;
        if (node.hasChildren && node.isExpanded) {
          recursionNode(node, nodeChildren);
        }
        Widget nodeView = itemView(
          subNodeBuilder?.call(node) ?? subNodeView(node),
          children: nodeChildren,
          padding: node.nodeDepth * (leftPadding ?? 25).toDouble(),
        );
        children.add(nodeView);
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    Widget treeView = itemView(topNodeBuilder?.call(node) ?? topNodeView(node), padding: leftPadding ?? 0, children: recursionNode(node, children));

    return Container(
      alignment: Alignment.topLeft,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: horizontalExpanded
            ? Container(
                child: treeView,
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  child: treeView,
                ),
              ),
      ),
    );
  }

  Widget itemView(Widget parentView, {List<Widget>? children, double padding = 0}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          parentView,
          if (children != null && children.length > 0)
            Padding(
              padding: EdgeInsets.only(left: padding),
              child: lineWidget != null
                  ? IntrinsicHeight(
                      child: Row(
                        children: [
                          lineWidget!,
                          if (horizontalExpanded) Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
                          if (!horizontalExpanded) Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                        ],
                      ),
                    )
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
        ],
      ),
    );
  }
}
