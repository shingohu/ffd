import 'package:flutter/material.dart';

typedef ItemCallBack = void Function(int index);
typedef ItemBuilder = Widget Function(int index);

///单选
showSingleBottomSheet(BuildContext context, {required int length, required ItemBuilder builder, ItemCallBack? itemCallBack, double maxHeight = 0.7, Color? color}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: color,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(length , (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      itemCallBack?.call(index);
                    },
                    child: builder(index),
                  );
                })),
          ),
        );
      });
}

///自定义
showCustomBottomSheet(BuildContext context, {required Widget child, Widget? header}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: UnconstrainedBox(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (header != null) header,
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
