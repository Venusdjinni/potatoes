import 'dart:ui';

import 'package:flutter/widgets.dart';

abstract class PotatoesMessage {
  static const String _localeFr = 'fr';
  static const String _localeEn = 'en';

  static String loading(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context)
      ?? PlatformDispatcher.instance.locale;

    switch (locale.languageCode) {
      case _localeFr: return "Chargement…";
      case _localeEn:
      default:
        return "Loading…";
    }
  }

  static String errorOccurred(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context)
      ?? PlatformDispatcher.instance.locale;

    switch (locale.languageCode) {
      case _localeFr: return "Une erreur est survenue";
      case _localeEn:
      default:
        return "error occured";
    }
  }
}