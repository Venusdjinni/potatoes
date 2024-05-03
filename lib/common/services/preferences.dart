import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [PreferencesService] is an adapter of the regular [SharedPreferences]
/// providing more organization to the preferences management and preventing
/// misuses
abstract class PreferencesService {
  @protected
  final SharedPreferences preferences;

  const PreferencesService(this.preferences);

  @protected
  String flavorPrefix() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    return flavor.isEmpty ? '' : '${flavor}_';
  }

  /// You do not call this method by yourself, instead it is used by [DioClient]
  /// to inject authentication headers into your requests that may be stored
  /// into the [PreferencesService].
  /// The implementation of this method should return a map of all headers you
  /// may want to add to your request when calling [ApiService.withAuth]. Values
  /// will be appended to the current headers of the request
  FutureOr<Map<String, String>> getAuthHeaders();

  /// clear all preferences managers
  Future<void> clear() {
    return preferences.clear();
  }
}