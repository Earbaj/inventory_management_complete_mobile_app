import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../error/failures.dart';

/// Callback invoked when an authenticated API call receives a 401 Unauthorized response.
typedef OnUnauthorizedCallback = void Function();

/// Core Network API Client (Dio Engine)
///
/// Handles HTTP communications, automatic Bearer JWT Token injection via request interceptors,
/// and global 401 Unauthorized session expiration handling without infinite loops.
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  /// Global callback triggered on 401 Unauthorized status for authenticated routes.
  OnUnauthorizedCallback? onUnauthorized;

  ApiClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _setupInterceptors();
  }

  /// Updates active Bearer JWT Token used in request interceptors.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Clears active Bearer JWT Token on logout or session expiration.
  void clearAuthToken() {
    _authToken = null;
  }

  /// Sets up Dio Interceptors for request token injection and error handling.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // 1. Request Interceptor: Injects Authorization Header if available
        onRequest: (options, handler) {
          final isPublic = options.extra['isPublic'] == true;
          if (!isPublic && _authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },

        // 2. Error Interceptor: Loop-Safe 401 Unauthorized Handling
        onError: (DioException error, handler) {
          final statusCode = error.response?.statusCode;
          final isPublic = error.requestOptions.extra['isPublic'] == true;

          // Prevent loop: Only trigger 401 auto logout on authenticated routes
          if (statusCode == 401 && !isPublic && onUnauthorized != null) {
            onUnauthorized!();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Performs an HTTP POST request.
  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isPublic = false,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          extra: {'isPublic': isPublic},
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  /// Performs an HTTP GET request.
  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isPublic = false,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          extra: {'isPublic': isPublic},
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  /// Performs an HTTP PUT request.
  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isPublic = false,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          extra: {'isPublic': isPublic},
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  /// Performs an HTTP DELETE request.
  Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isPublic = false,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          extra: {'isPublic': isPublic},
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure(e.toString());
    }
  }

  /// Decodes and validates HTTP response payload.
  dynamic _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 200;

    if (statusCode >= 200 && statusCode < 300) {
      return response.data;
    }

    throw ServerFailure('Server error ($statusCode)', statusCode: statusCode);
  }

  /// Maps [DioException] instances to domain [Failure] objects.
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Network connection timeout. Please check your internet.');
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const UnauthorizedFailure('Session expired or invalid credentials.');
    }

    String errorMessage = 'Server error (${statusCode ?? 'Unknown'})';
    final responseData = e.response?.data;
    if (responseData is Map && responseData.containsKey('message')) {
      errorMessage = responseData['message'].toString();
    } else if (e.message != null && e.message!.isNotEmpty) {
      errorMessage = e.message!;
    }

    return ServerFailure(errorMessage, statusCode: statusCode);
  }
}
