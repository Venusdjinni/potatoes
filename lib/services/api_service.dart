import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:potatoes/services/preferences.dart';
import 'package:potatoes/utils/links.dart';

const String _authHeaderIndicator = 'Authorization';

abstract class DioClient {
  static Dio newInstance(
    PreferencesService preferences,
    PackageInfo packageInfo
  ) {
    log('running on: ${Links.instance.server}');

    return Dio()
      ..options.baseUrl = Links.instance.server
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 50)
      ..options.headers['Accept'] = 'application/json'
      ..options.headers['app_version'] = packageInfo.buildNumber
      ..interceptors.add(_ApiInterceptors(preferences));
  }
}

class _ApiInterceptors extends Interceptor {
  final PreferencesService preferences;

  _ApiInterceptors(this.preferences);

  Future<Map<String, String>> _getAuth() async {
    return preferences.getAuthHeaders();
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    log("${options.method} request in progress ${options.uri}");

    if (options.headers.containsKey(_authHeaderIndicator)) {
      options.headers.addAll(await _getAuth());
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    log('API Error on ${err.requestOptions.method} ${err.requestOptions.path}: ${err.message} ${err.response?.data}');
    return super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("API success on ${response.requestOptions.method} ${response.requestOptions.path} (${response.statusCode}): ${response.data}");
    return super.onResponse(response, handler);
  }
}

abstract class ApiService {
  final Dio _dio;
  Dio get dio => _dio;

  const ApiService(this._dio);

  Future<T> compute<T>(
    Future<Response> request, {
      String? mapperKey,
      T Function(Map<String, dynamic>)? mapper,
      T Function(String)? messageMapper,
    }
  );

  // cette methode va signaler à l'interceptor qu'il faut injecter les headers
  // d'authentification
  Map<String, dynamic> withAuth() => <String, String>{_authHeaderIndicator : ''};
}