import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  static const String _keyIsFirstRun = 'is_first_run';
  final SharedPreferences preferences;

  const PreferencesService(this.preferences);

  @protected
  String flavorPrefix() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    return flavor.isEmpty ? '' : '${flavor}_';
  }

  bool get isFirstRun => preferences.getBool('${flavorPrefix()}$_keyIsFirstRun') ?? true;

  Future<void> saveIsFirstRun(bool value) => preferences.setBool('${flavorPrefix()}$_keyIsFirstRun', value);

  FutureOr<Map<String, String>> getAuthHeaders();

  Future<void> clear() async {
    await preferences.clear();
    return saveIsFirstRun(false);
  }
}