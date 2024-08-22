import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:potatoes/common/services/preferences.dart';

/// The header key used to request auth injection
const String _authHeaderIndicator = 'Authorization';

/// [Links] is a multi-purpose class made to handle HTTP links with your app.
/// Its used by [DioClient] to setup new instances
abstract class Links {
  static Links? _instance;
  static Links get instance {
    if (_instance == null) {
      throw UnimplementedError('Links is not globally defined yet');
    }
    return _instance!;
  }

  static set instance(Links value) {
    _instance ??= value;
  }

  const Links();

  /// returns an url based on the value of the environment variable 'FLAVOR'.
  /// Possible values are 'production', 'dev' and 'staging'.
  /// Defaults to 'production'
  String get server {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');
    switch (flavor) {
      case 'dev': return devUrl;
      case 'staging': return stagingUrl;
      default: return productionUrl;
    }
  }

  /// the server url for the production environment
  String get productionUrl;
  /// the server url for the staging/testing environment
  String get stagingUrl;
  /// the server url for the development environment
  String get devUrl;
}

/// This class's only purpose is to instantiate new [Dio] objects
abstract class DioClient {
  /// returns a new Dio instance configured with some basic features
  static Dio instance(
    PreferencesService preferences,
    {
      /// if this is set to true, then all status errors will lead to a success
      /// in the Future execution. By default, only statuses between 200 and 300
      /// are considered as success.
      /// See. https://github.com/cfug/dio/blob/87e6b1d4c8f9d3c57dd2291f540b730b510f4b20/dio/lib/src/options.dart#L633
      bool disableStatusesErrors = false,
      Duration? connectTimeout = const Duration(seconds: 30),
      Duration? sendTimeout = const Duration(seconds: 50),
      Duration? receiveTimeout,
      /// use this to override the default server link obtained from [Links]
      String? baseUrl
    }
  ) {
    log('running on: ${baseUrl ?? Links.instance.server}');

    final dio = Dio()
      ..options.baseUrl = baseUrl?? Links.instance.server
      ..options.connectTimeout = connectTimeout
      ..options.sendTimeout = sendTimeout
      ..options.receiveTimeout = receiveTimeout
      ..options.headers['Accept'] = 'application/json'
      ..interceptors.add(_AuthorizationInterceptor(preferences))
      ..interceptors.add(const _LogInterceptor());

    if (disableStatusesErrors) {
      dio.options.validateStatus = (_) => true;
    }

    return dio;
  }
}

/// This interceptor handles authorization headers injection by calling
/// [PreferencesService] getAuthHeaders when authorization should be provided
class _AuthorizationInterceptor extends Interceptor {
  final PreferencesService preferences;

  _AuthorizationInterceptor(this.preferences);

  FutureOr<Map<String, String>> _getAuth() {
    return preferences.getAuthHeaders();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers.containsKey(_authHeaderIndicator)) {
      options.headers.addAll(await _getAuth());
    }
    return super.onRequest(options, handler);
  }
}

/// This interceptor logs request events
class _LogInterceptor extends Interceptor {
  const _LogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log("${options.method} request in progress ${options.uri}");
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('API Error on ${err.requestOptions.method} ${err.requestOptions.path}: ${err.message} ${err.response?.data}');
    return super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("API success on ${response.requestOptions.method} ${response.requestOptions.path} (${response.statusCode}): ${response.data}");
    return super.onResponse(response, handler);
  }
}

/// [ApiService] is the main class to use to make API calls. This use
/// an instance of [Dio] (possibly created using [DioClient]) and has several
/// methods to automatize data extraction
abstract class ApiService {
  final Dio _dio;
  @protected
  Dio get dio => _dio;

  const ApiService(this._dio);

  @protected
  T defaultExtractResult<T>(
    Map<String, dynamic> data,
    String? mapperKey,
    T Function(Map<String, dynamic>)? mapper,
    T Function(String)? messageMapper,
  ) {
    assert(mapper == null || messageMapper == null);
    if (messageMapper != null) {
      return messageMapper(data['message']);
    }
    dynamic result = data;
    if (mapper != null) {
      result = mapperKey == null ? result : result[mapperKey];
      return mapper(result);
    } else {
      return mapperKey == null ? result : result[mapperKey];
    }
  }

  /// A [Dio] fetch call needs to be computed to extract data or resolve to
  /// an [ApiError]. You are responsible of your compute logic as it should
  /// match with your needs.
  Future<T> compute<T>(
    Future<Response> request, {
      String? mapperKey,
      T Function(Map<String, dynamic>)? mapper,
      T Function(String)? messageMapper,
    }
  );

  /// Adding this to your [Dio] request options will trigger
  /// the [_AuthorizationInterceptor] to inject authorization headers before
  /// executing the API call.
  /// ```dart
  ///  Future<void> getUser() {
  //     return compute(
  //       dio.post(
  //         _getUserRoute,
  //         options: Options(headers: withAuth())
  //       )
  //     );
  //   }
  /// ```
  Map<String, dynamic> withAuth() => <String, String>{_authHeaderIndicator : ''};
}

/// This is a generic class to handle and display errors across your app.
/// [APIError] helps you track errors coming from API call and display an error
/// message accordingly. It also maintain the original Exception as well as the
/// stack trace
class ApiError extends Equatable implements Exception {
  final DioException? _dio;
  final String? _message;
  final StackTrace? _trace;
  final int _statusCode;

  /// Create an ApiError based on a [Dio] Exception
  ApiError.fromDio(DioException dio)
    : _dio = dio,
      _message = null,
      _trace = dio.stackTrace,
      _statusCode = dio.response?.statusCode ?? -1;

  /// Create an APIError from a custom error (eg. exception during data processing)
  const ApiError.unknown(String? message, [StackTrace? trace])
    : _dio = null,
      _message = message,
      _trace = trace,
      _statusCode = -1;

  /// The [DioException] originating this error
  DioException? get dio => _dio;

  /// The message from a custom error
  String? get message => _message;

  /// The stack trace of the error
  StackTrace? get trace => _trace;

  /// A convenience status code. -1 if unknown and [Dio.response.statusCode] if available
  int get statusCode => _statusCode;

  bool get isUnauthenticatedError => _statusCode == 401 || _statusCode == 403;

  bool get isNoInternetConnectionError => _statusCode == 503;

  @override
  List<Object?> get props => [_dio, _trace, _statusCode];
}