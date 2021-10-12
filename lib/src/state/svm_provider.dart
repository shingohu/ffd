import 'package:ffd/src/app/lifecycler.dart';
import 'package:ffd/src/app/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vm.dart';

abstract class SVMWidget<T extends ViewModel> extends StatelessWidget with IPageLifecycle, LoadingMixin {

  const SVMWidget({ Key? key }) : super(key: key);


  T createModel(BuildContext context);

  T create(BuildContext context) {
    T model = createModel(context);
    model.toastListen = toastListen;
    model.loadingListen = (show) {
      loadingListen(show, context: context);
    };
    return model;
  }

  Widget builder(BuildContext context, T model);

  @override
  Widget build(BuildContext context) {
    return ViewModelWidget<T>(
      create: create,
      builder: builder,
      onCreate: onCreate,
      onResume: onResume,
      onDispose: onDispose,
      onPause: onPause,
    );
  }
}

//最好是在statelessWidget中使用,因为Consumer在跳转的时候会重复刷新
//statefullwidget 在跳转的时候也会rebuild
class ViewModelWidget<T extends ViewModel> extends StatelessWidget {
  final Create<T> create;
  final Widget Function(BuildContext context, T vm) builder;
  final Function(BuildContext context)? onResume;
  final Function(BuildContext context)? onPause;
  final Function(BuildContext context)? onDispose;
  final Function(BuildContext context)? onCreate;

  ViewModelWidget({
    Key? key,
    required this.create,
    required this.builder,
    this.onCreate,
    this.onResume,
    this.onPause,
    this.onDispose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (ctx) {
        T model = create(ctx);
        return model;
      },
      child: PageLifecycleWidget(
        onCreate: onCreate,
        onDispose: onDispose,
        onPause: onPause,
        onResume: onResume,
        child: Consumer<T>(
          builder: (context, vm, child) => builder(context, vm),
        ),
      ),
    );
  }
}
