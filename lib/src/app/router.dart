import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Widget RouterBuilder(BuildContext context, RouteSettings settings);

class MaterialRouter extends _Router {
  MaterialRouter(final Map<String, RouterBuilder> definitions)
      : super(definitions, page: <Null>(settings, builder) => new MaterialPageRoute<Null>(builder: builder, settings: settings));
}

class CupertinoRouter extends _Router {
  CupertinoRouter(final Map<String, RouterBuilder> definitions)
      : super(definitions, page: <Null>(settings, builder) => new CupertinoPageRoute<Null>(settings: settings, builder: builder));
}

abstract class _Router {
  _Router(this.definitions, {required this.page});

  Route<dynamic>? get(final RouteSettings settings) {
    final matches = this.definitions.keys.where((route) => route == settings.name);
    final route = matches.length > 0 ? matches.first : null;

    return null != route
        ? this.page(settings, (ctx) {
            return (definitions[route])!.call(ctx, settings);
          })
        : null;
  }

  final Map<String, RouterBuilder> definitions;
  final PageRouteFactory page;
}
