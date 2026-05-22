import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_config.dart';

class ApiClient {
  ApiClient({String? baseUrl, Duration timeout = const Duration(seconds: 8)})
    : _baseUrl = Uri.parse(baseUrl ?? ApiConfig.baseUrl),
      _timeout = timeout;

  final Uri _baseUrl;
  final Duration _timeout;

  Future<Map<String, Object?>> getHealth() {
    return _requestJson('GET', '/api/health');
  }

  Future<AuthResponse> loginWithKakaoAccessToken(String accessToken) async {
    final json = await _requestJson(
      'POST',
      '/api/mobile/auth/kakao',
      body: {'accessToken': accessToken},
    );

    return AuthResponse.fromJson(json);
  }

  Future<Map<String, Object?>> getMe(String sessionToken) {
    return _requestJson(
      'GET',
      '/api/mobile/auth/me',
      bearerToken: sessionToken,
    );
  }

  Future<Map<String, Object?>> _requestJson(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? bearerToken,
  }) async {
    final client = HttpClient();

    try {
      final request = await client
          .openUrl(method, _baseUrl.resolve(path))
          .timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      if (bearerToken != null) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $bearerToken',
        );
      }

      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty
          ? <String, Object?>{}
          : jsonDecode(responseBody) as Map<String, Object?>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, decoded);
      }

      return decoded;
    } on SocketException catch (error) {
      throw ApiConnectionException(error.message);
    } on TimeoutException {
      throw const ApiConnectionException('요청 시간이 초과되었습니다.');
    } finally {
      client.close(force: true);
    }
  }
}

class AuthResponse {
  const AuthResponse({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final AppUser user;

  factory AuthResponse.fromJson(Map<String, Object?> json) {
    return AuthResponse(
      tokenType: json['tokenType'] as String,
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: AppUser.fromJson(json['user'] as Map<String, Object?>),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.nickname,
    required this.lastLoginAt,
  });

  final String id;
  final String nickname;
  final String? lastLoginAt;

  factory AppUser.fromJson(Map<String, Object?> json) {
    return AppUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      lastLoginAt: json['last_login_at'] as String?,
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;

  @override
  String toString() => 'HTTP $statusCode: ${jsonEncode(body)}';
}

class ApiConnectionException implements Exception {
  const ApiConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}
