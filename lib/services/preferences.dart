import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  static const String _keyIsFirstRun = 'is_first_run';
  final SharedPreferences _preferences;

  const PreferencesService(SharedPreferences preferences)
    : _preferences = preferences;

  @protected
  String flavorPrefix() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    return flavor.isEmpty ? '' : '${flavor}_';
  }

  bool get isFirstRun => _preferences.getBool('${flavorPrefix()}$_keyIsFirstRun') ?? true;

  Future<void> saveIsFirstRun(bool value) => _preferences.setBool('${flavorPrefix()}$_keyIsFirstRun', value);

  FutureOr<Map<String, String>> getAuthHeaders();

  Future<void> clear() async {
    await _preferences.clear();
    return saveIsFirstRun(false);
  }
}

abstract class SecuredPreferencesService extends PreferencesService {
  final FlutterSecureStorage _secureStorage;

  const SecuredPreferencesService(super.preferences, FlutterSecureStorage storage)
    : _secureStorage = storage;

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
    return super.clear();
  }
}