import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<Map<String, String>> _headers({
    String? token,
    Map<String, String>? extraHeaders,
  }) async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extraHeaders,
    };
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    return _send(
      () async => _client.get(
        _uri(path, queryParameters),
        headers: await _headers(token: token),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _send(
      () async => _client.post(
        _uri(path),
        headers: await _headers(token: token),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _send(
      () async => _client.put(
        _uri(path),
        headers: await _headers(token: token),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> delete(String path, {String? token}) async {
    return _send(
      () async =>
          _client.delete(_uri(path), headers: await _headers(token: token)),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(AppConfig.apiTimeout);

      final body = response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode == 401) {
        throw const UnauthorizedException();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: body is Map && body['message'] != null
              ? body['message'].toString()
              : 'Request failed.',
          statusCode: response.statusCode,
          code: 'API_ERROR',
          cause: body,
        );
      }

      return body;
    } on TimeoutException catch (error) {
      throw NetworkException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
        cause: error,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw NetworkException(
        message: 'Network request failed.',
        code: 'NETWORK_ERROR',
        cause: error,
      );
    }
  }
}
