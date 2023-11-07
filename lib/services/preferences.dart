import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  static const String _keyIsFirstRun = 'is_first_run';
  @protected
  final SharedPreferences preferences;

  const PreferencesService(SharedPreferences preferences)
    : preferences = preferences;

  @protected
  String flavorPrefix() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    return flavor.isEmpty ? '' : '${flavor}_';
  }

  bool get isFirstRun => preferences.getBool('${flavorPrefix()}$_keyIsFirstRun') ?? true;

  Future<void> saveIsFirstRun(bool value) => preferences.setBool('${flavorPrefix()}$_keyIsFirstRun', value);

  FutureOr<Map<String, String>> getAuthHeaders();

  Future<void> clear() {
    return preferences.clear();
  }
}

abstract class SecuredPreferencesService extends PreferencesService {
  @protected
  final FlutterSecureStorage secureStorage;

  const SecuredPreferencesService(super.preferences, FlutterSecureStorage secureStorage)
    : secureStorage = secureStorage;

  @override
  Future<void> clear() async {
    await secureStorage.deleteAll();
    return super.clear();
  }
}