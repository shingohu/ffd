import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

///how to use
/// 1定义一个抽象类S
// abstract class S extends L {
//   static S get current => L.current;
// }
///2定义实现类
//class $EN extends S {}
///3配置 supportedLocales以及locales
///
/// 使用时直接S.xxx

///默认的国际化代理
const Iterable<LocalizationsDelegate<dynamic>> kLocalizationsDelegates = [
  GlobalCupertinoLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

class L implements WidgetsLocalizations {
  const L();

  static late L current;

  static GeneratedLocalizationsDelegate delegate(Map<Locale, L> locales) {
    return GeneratedLocalizationsDelegate(locales);
  }

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<L> {
  final Map<Locale, L> locales;

  const GeneratedLocalizationsDelegate(this.locales);

  List<Locale> get supportedLocales {
    return locales.keys.toList();
  }

  LocaleListResolutionCallback listResolution({Locale? fallback, bool withCountry = true}) {
    return (List<Locale>? locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution({Locale? fallback, bool withCountry = true}) {
    return (Locale? locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<L> load(Locale locale) {
    final String? lang = getLang(locale);
    //L.current = null;
    if (lang != null) {
      locales.forEach((ll, s) {
        if (getLang(ll) == lang) {
          L.current = s;
          return;
        }
      });
    }
    return SynchronousFuture<L>(L.current);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale? locale, Locale? fallback, Iterable<Locale> supported, bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale? locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode!.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String? getLang(Locale? l) => l == null
    ? null
    : l.countryCode == null || l.countryCode!.isEmpty
        ? l.languageCode
        : l.toString();
